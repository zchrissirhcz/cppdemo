// demo9: pure C++ (no third-party libs) image undistortion demo
// Input/Output format: binary PPM (P6)
// Camera model: pinhole + Brown-Conrady distortion (k1 k2 p1 p2 k3)

#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

struct ImageRGB8 {
	int w = 0;
	int h = 0;
	std::vector<uint8_t> data; // size = w*h*3
};

struct CameraParams {
	double fx = 0.0;
	double fy = 0.0;
	double cx = 0.0;
	double cy = 0.0;
	double k1 = 0.0;
	double k2 = 0.0;
	double p1 = 0.0;
	double p2 = 0.0;
	double k3 = 0.0;
};

static bool readToken(std::istream& is, std::string& token)
{
	token.clear();
	for (;;) {
		int c = is.peek();
		if (c == EOF) return false;
		if (std::isspace(c)) {
			is.get();
			continue;
		}
		if (c == '#') {
			// comment to end of line
			std::string dummy;
			std::getline(is, dummy);
			continue;
		}
		break;
	}
	is >> token;
	return static_cast<bool>(is);
}

static bool loadPPM_P6(const std::string& path, ImageRGB8& out)
{
	std::ifstream ifs(path.c_str(), std::ios::binary);
	if (!ifs) return false;

	std::string magic;
	if (!readToken(ifs, magic)) return false;
	if (magic != "P6") return false;

	std::string sw, sh, smax;
	if (!readToken(ifs, sw) || !readToken(ifs, sh) || !readToken(ifs, smax)) return false;

	const int w = std::atoi(sw.c_str());
	const int h = std::atoi(sh.c_str());
	const int maxv = std::atoi(smax.c_str());
	if (w <= 0 || h <= 0) return false;
	if (maxv != 255) return false;

	// consume single whitespace char after header before binary payload
	int c = ifs.get();
	if (c == EOF) return false;

	out.w = w;
	out.h = h;
	out.data.assign(static_cast<size_t>(w) * static_cast<size_t>(h) * 3u, 0);
	ifs.read(reinterpret_cast<char*>(out.data.data()), static_cast<std::streamsize>(out.data.size()));
	return static_cast<size_t>(ifs.gcount()) == out.data.size();
}

static bool savePPM_P6(const std::string& path, const ImageRGB8& img)
{
	if (img.w <= 0 || img.h <= 0) return false;
	if (img.data.size() != static_cast<size_t>(img.w) * static_cast<size_t>(img.h) * 3u) return false;

	std::ofstream ofs(path.c_str(), std::ios::binary);
	if (!ofs) return false;
	ofs << "P6\n" << img.w << " " << img.h << "\n255\n";
	ofs.write(reinterpret_cast<const char*>(img.data.data()), static_cast<std::streamsize>(img.data.size()));
	return static_cast<bool>(ofs);
}

static bool loadCameraParamsTxt(const std::string& path, CameraParams& out)
{
	std::ifstream ifs(path.c_str());
	if (!ifs) return false;

	// Format (whitespace separated, comments allowed with '#'):
	// fx fy cx cy
	// k1 k2 p1 p2 k3
	std::string token;
	double v[9];
	for (int i = 0; i < 9; ++i) {
		if (!readToken(ifs, token)) return false;
		std::istringstream iss(token);
		iss >> v[i];
		if (!iss) return false;
	}

	out.fx = v[0];
	out.fy = v[1];
	out.cx = v[2];
	out.cy = v[3];
	out.k1 = v[4];
	out.k2 = v[5];
	out.p1 = v[6];
	out.p2 = v[7];
	out.k3 = v[8];
	if (out.fx <= 0.0 || out.fy <= 0.0) return false;
	return true;
}

static inline double clampd(double x, double lo, double hi)
{
	return std::max(lo, std::min(hi, x));
}

static inline uint8_t clamp8(int v)
{
	if (v < 0) return 0;
	if (v > 255) return 255;
	return static_cast<uint8_t>(v);
}

static void sampleBilinearRGB(const ImageRGB8& img, double x, double y, uint8_t out_rgb[3])
{
	// x,y in pixel coordinates
	if (x < 0.0 || y < 0.0 || x > (img.w - 1) || y > (img.h - 1)) {
		out_rgb[0] = out_rgb[1] = out_rgb[2] = 0;
		return;
	}

	const int x0 = static_cast<int>(std::floor(x));
	const int y0 = static_cast<int>(std::floor(y));
	const int x1 = std::min(x0 + 1, img.w - 1);
	const int y1 = std::min(y0 + 1, img.h - 1);
	const double ax = x - x0;
	const double ay = y - y0;

	const size_t idx00 = (static_cast<size_t>(y0) * img.w + x0) * 3u;
	const size_t idx10 = (static_cast<size_t>(y0) * img.w + x1) * 3u;
	const size_t idx01 = (static_cast<size_t>(y1) * img.w + x0) * 3u;
	const size_t idx11 = (static_cast<size_t>(y1) * img.w + x1) * 3u;

	for (int c = 0; c < 3; ++c) {
		const double v00 = img.data[idx00 + c];
		const double v10 = img.data[idx10 + c];
		const double v01 = img.data[idx01 + c];
		const double v11 = img.data[idx11 + c];

		const double v0 = v00 * (1.0 - ax) + v10 * ax;
		const double v1 = v01 * (1.0 - ax) + v11 * ax;
		const double v = v0 * (1.0 - ay) + v1 * ay;
		out_rgb[c] = clamp8(static_cast<int>(std::lround(v)));
	}
}

static inline void distortNormalized(const CameraParams& p, double x, double y, double& xd, double& yd)
{
	const double r2 = x * x + y * y;
	const double r4 = r2 * r2;
	const double r6 = r4 * r2;
	const double radial = 1.0 + p.k1 * r2 + p.k2 * r4 + p.k3 * r6;

	const double x_tan = 2.0 * p.p1 * x * y + p.p2 * (r2 + 2.0 * x * x);
	const double y_tan = p.p1 * (r2 + 2.0 * y * y) + 2.0 * p.p2 * x * y;

	xd = x * radial + x_tan;
	yd = y * radial + y_tan;
}

static ImageRGB8 undistortSameK(const ImageRGB8& src, const CameraParams& p)
{
	ImageRGB8 dst;
	dst.w = src.w;
	dst.h = src.h;
	dst.data.assign(static_cast<size_t>(dst.w) * static_cast<size_t>(dst.h) * 3u, 0);

	for (int v = 0; v < dst.h; ++v) {
		for (int u = 0; u < dst.w; ++u) {
			const double x = (static_cast<double>(u) - p.cx) / p.fx;
			const double y = (static_cast<double>(v) - p.cy) / p.fy;

			double xd = 0.0;
			double yd = 0.0;
			distortNormalized(p, x, y, xd, yd);

			const double us = p.fx * xd + p.cx;
			const double vs = p.fy * yd + p.cy;

			uint8_t rgb[3];
			sampleBilinearRGB(src, us, vs, rgb);

			const size_t idx = (static_cast<size_t>(v) * dst.w + u) * 3u;
			dst.data[idx + 0] = rgb[0];
			dst.data[idx + 1] = rgb[1];
			dst.data[idx + 2] = rgb[2];
		}
	}

	return dst;
}

static void printUsage(const char* argv0)
{
	std::cerr
		<< "Usage:\n"
		<< "  " << argv0 << " undistort <input.ppm> <output.ppm> <params.txt>\n\n"
		<< "params.txt format (whitespace separated, '#' comments allowed):\n"
		<< "  fx fy cx cy\n"
		<< "  k1 k2 p1 p2 k3\n";
}

int main(int argc, char** argv)
{
	if (argc < 2) {
		printUsage(argv[0]);
		return 2;
	}

	const std::string cmd = argv[1];
	if (cmd == "undistort") {
		if (argc != 5) {
			printUsage(argv[0]);
			return 2;
		}

		const std::string inPath = argv[2];
		const std::string outPath = argv[3];
		const std::string paramsPath = argv[4];

		CameraParams p;
		if (!loadCameraParamsTxt(paramsPath, p)) {
			std::cerr << "Failed to load params: " << paramsPath << "\n";
			return 1;
		}

		ImageRGB8 img;
		if (!loadPPM_P6(inPath, img)) {
			std::cerr << "Failed to load PPM(P6): " << inPath << "\n";
			return 1;
		}

		ImageRGB8 und = undistortSameK(img, p);
		if (!savePPM_P6(outPath, und)) {
			std::cerr << "Failed to save PPM(P6): " << outPath << "\n";
			return 1;
		}

		std::cout << "OK: wrote " << outPath << "\n";
		return 0;
	}

	printUsage(argv[0]);
	return 2;
}

