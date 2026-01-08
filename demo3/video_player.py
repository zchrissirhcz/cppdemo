"""
视频播放器 - 使用 av 库读取 H.264/H.265 视频文件并通过 OpenCV 显示

依赖:
    pip install av opencv-python

使用方法:
    python video_player.py [video_file.h264|h265]
    如果不指定文件，将使用默认视频路径
"""

import sys
import os
import av
import cv2
import numpy as np


def get_zzpkg_root():
    """获取 ZZPKG_ROOT 路径"""
    zzpkg_root_env = os.environ.get("ZZPKG_ROOT")
    if zzpkg_root_env:
        return zzpkg_root_env
    else:
        # 扩展 '~' 到用户主目录
        home_env = os.environ.get("HOME")
        if not home_env:
            home_env = os.environ.get("USERPROFILE")  # for Windows
        if home_env:
            return os.path.join(home_env, ".zzpkg")
        else:
            return "~/.zzpkg"


def play_video(video_path):
    """
    读取并播放 H.264/H.265 视频文件
    
    Args:
        video_path: 视频文件路径
    """
    try:
        # 打开视频文件
        container = av.open(video_path)
        
        # 获取视频流
        video_stream = container.streams.video[0]
        
        print(f"视频信息:")
        print(f"  编码格式: {video_stream.codec_context.name}")
        print(f"  分辨率: {video_stream.width}x{video_stream.height}")
        print(f"  帧率: {video_stream.average_rate}")
        print(f"  总帧数: {video_stream.frames}")
        print("\n按 'q' 或 ESC 退出播放")
        
        # 创建窗口
        window_name = f"Video Player - {video_path}"
        cv2.namedWindow(window_name, cv2.WINDOW_NORMAL)
        
        # 计算帧间延迟 (毫秒)
        if video_stream.average_rate:
            fps = float(video_stream.average_rate)
            delay = int(1000 / fps) if fps > 0 else 30
        else:
            delay = 30  # 默认延迟
        
        frame_count = 0
        
        # 解码并显示视频帧
        for frame in container.decode(video=0):
            # 将 av.VideoFrame 转换为 numpy 数组
            img = frame.to_ndarray(format='bgr24')
            
            frame_count += 1
            
            # 在图像上显示帧号
            cv2.putText(img, f"Frame: {frame_count}", (10, 30),
                       cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
            
            # 显示图像
            cv2.imshow(window_name, img)
            
            # 等待按键
            key = cv2.waitKey(delay) & 0xFF
            if key == ord('q') or key == 27:  # 'q' 或 ESC
                print(f"\n用户退出 (已播放 {frame_count} 帧)")
                break
        
        print(f"\n播放完成，共 {frame_count} 帧")
        
        # 关闭资源
        container.close()
        cv2.destroyAllWindows()
        
    except av.AVError as e:
        print(f"av 库错误: {e}")
        sys.exit(1)
    except FileNotFoundError:
        print(f"错误: 找不到文件 '{video_path}'")
        sys.exit(1)
    except Exception as e:
        print(f"发生错误: {e}")
        sys.exit(1)


def main():
    if len(sys.argv) == 2:
        video_path = sys.argv[1]
    else:
        # 使用默认视频路径
        ZZPKG_ROOT = get_zzpkg_root()
        print(f"ZZPKG_ROOT: {ZZPKG_ROOT}")
        # 默认使用 H.265 视频文件
        video_path = os.path.join(ZZPKG_ROOT, "h265_data", "0.1", "surfing.265")
        # 或者使用 H.264 视频文件:
        # video_path = os.path.join(ZZPKG_ROOT, "h264_data", "0.1", "3min_1080p.h264")
        print(f"使用默认视频路径: {video_path}")
        print("提示: 也可以指定视频文件: python video_player.py <video_file>\n")
    
    # 检查文件扩展名
    if not (video_path.lower().endswith('.h264') or 
            video_path.lower().endswith('.h265') or
            video_path.lower().endswith('.264') or
            video_path.lower().endswith('.265')):
        print("警告: 文件扩展名不是 .h264 或 .h265，但仍会尝试播放")
    
    play_video(video_path)


if __name__ == "__main__":
    main()
