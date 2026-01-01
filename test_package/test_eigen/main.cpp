#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Core>

int main() {
    std::cout << "Eigen Version: " << EIGEN_WORLD_VERSION << "."
              << EIGEN_MAJOR_VERSION << "."
              << EIGEN_MINOR_VERSION << std::endl;

    // 示例1: 矩阵基本操作
    Eigen::Matrix3d mat;
    mat << 1, 2, 3,
           4, 5, 6,
           7, 8, 9;
    
    std::cout << "\n原始矩阵:\n" << mat << std::endl;
    std::cout << "\n转置矩阵:\n" << mat.transpose() << std::endl;

    // 示例2: 向量操作
    Eigen::Vector3d vec(1.0, 2.0, 3.0);
    std::cout << "\n向量:\n" << vec << std::endl;
    std::cout << "向量长度: " << vec.norm() << std::endl;

    // 示例3: 矩阵乘法
    Eigen::MatrixXd A = Eigen::MatrixXd::Random(3, 3);
    Eigen::MatrixXd B = Eigen::MatrixXd::Random(3, 3);
    Eigen::MatrixXd C = A * B;
    
    std::cout << "\n矩阵A:\n" << A << std::endl;
    std::cout << "\n矩阵B:\n" << B << std::endl;
    std::cout << "\nA * B:\n" << C << std::endl;

    // 示例4: 线性方程求解 Ax = b
    Eigen::Matrix3d A_eq;
    A_eq << 1, 2, 3,
            4, 5, 6,
            7, 8, 10;
    
    Eigen::Vector3d b_eq(3, 3, 4);
    Eigen::Vector3d x = A_eq.colPivHouseholderQr().solve(b_eq);
    
    std::cout << "\n求解 Ax = b" << std::endl;
    std::cout << "解 x:\n" << x << std::endl;
    std::cout << "验证 Ax:\n" << A_eq * x << std::endl;

    // 示例5: 特征值分解
    Eigen::Matrix2d mat2;
    mat2 << 1, 2,
            2, 3;
    
    Eigen::SelfAdjointEigenSolver<Eigen::Matrix2d> eigensolver(mat2);
    if (eigensolver.info() == Eigen::Success) {
        std::cout << "\n特征值:\n" << eigensolver.eigenvalues() << std::endl;
        std::cout << "\n特征向量:\n" << eigensolver.eigenvectors() << std::endl;
    }

    return 0;
}