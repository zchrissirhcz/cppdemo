#!/usr/bin/env python3
"""
相机标定坐标系可视化
展示从世界坐标系到像素坐标系的完整转换过程
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.patches import Rectangle
import matplotlib.patches as mpatches

# 设置中文字体
plt.rcParams['font.sans-serif'] = ['Arial Unicode MS', 'SimHei', 'DejaVu Sans']
plt.rcParams['axes.unicode_minus'] = False

def draw_coordinate_system(ax, origin, size=1, label='', colors=['r', 'g', 'b']):
    """绘制3D坐标系"""
    x, y, z = origin
    
    # X轴 (红色)
    ax.quiver(x, y, z, size, 0, 0, color=colors[0], arrow_length_ratio=0.1, linewidth=2)
    ax.text(x + size*1.1, y, z, f'X{label}', color=colors[0], fontsize=10, fontweight='bold')
    
    # Y轴 (绿色)
    ax.quiver(x, y, z, 0, size, 0, color=colors[1], arrow_length_ratio=0.1, linewidth=2)
    ax.text(x, y + size*1.1, z, f'Y{label}', color=colors[1], fontsize=10, fontweight='bold')
    
    # Z轴 (蓝色)
    ax.quiver(x, y, z, 0, 0, size, color=colors[2], arrow_length_ratio=0.1, linewidth=2)
    ax.text(x, y, z + size*1.1, f'Z{label}', color=colors[2], fontsize=10, fontweight='bold')

def draw_camera(ax, position, target, size=1.5):
    """绘制相机模型"""
    # 计算相机朝向
    direction = np.array(target) - np.array(position)
    direction = direction / np.linalg.norm(direction)
    
    # 相机位置
    cx, cy, cz = position
    
    # 绘制相机主体（金字塔形状）
    # 相机光心
    ax.scatter([cx], [cy], [cz], color='orange', s=100, marker='^', label='相机光心')
    
    # 相机朝向箭头
    ax.quiver(cx, cy, cz, direction[0]*size, direction[1]*size, direction[2]*size, 
              color='orange', arrow_length_ratio=0.2, linewidth=2, label='相机朝向')
    
    # 绘制视锥（简化的三角形）
    up = np.array([0, 0, 1])
    right = np.cross(direction, up)
    right = right / np.linalg.norm(right)
    up = np.cross(right, direction)
    
    # 视锥底面
    fov_size = size * 0.8
    center = np.array(position) + direction * size
    p1 = center + (right + up) * fov_size
    p2 = center + (right - up) * fov_size
    p3 = center + (-right - up) * fov_size
    p4 = center + (-right + up) * fov_size
    
    # 绘制视锥线
    for p in [p1, p2, p3, p4]:
        ax.plot([cx, p[0]], [cy, p[1]], [cz, p[2]], color='orange', linestyle='--', alpha=0.5)
    
    # 绘制底面
    ax.plot([p1[0], p2[0]], [p1[1], p2[1]], [p1[2], p2[2]], color='orange', linestyle='-', alpha=0.3)
    ax.plot([p2[0], p3[0]], [p2[1], p3[1]], [p2[2], p3[2]], color='orange', linestyle='-', alpha=0.3)
    ax.plot([p3[0], p4[0]], [p3[1], p4[1]], [p3[2], p4[2]], color='orange', linestyle='-', alpha=0.3)
    ax.plot([p4[0], p1[0]], [p4[1], p1[1]], [p4[2], p1[2]], color='orange', linestyle='-', alpha=0.3)

def draw_3d_point(ax, point, label='', color='purple', size=100):
    """绘制3D点"""
    ax.scatter([point[0]], [point[1]], [point[2]], color=color, s=size, marker='o', 
               edgecolors='black', linewidths=2, label=label)
    ax.text(point[0], point[1], point[2]+0.2, label, fontsize=9, fontweight='bold')

def draw_projection_line(ax, start, end, color='gray', linestyle='--'):
    """绘制投影线"""
    ax.plot([start[0], end[0]], [start[1], end[1]], [start[2], end[2]], 
            color=color, linestyle=linestyle, linewidth=1.5, alpha=0.7)

def visualize_world_to_camera():
    """可视化：世界坐标系 → 相机坐标系"""
    fig = plt.figure(figsize=(14, 10))
    ax = fig.add_subplot(111, projection='3d')
    
    # 设置标题
    ax.set_title('步骤1: 世界坐标系 → 相机坐标系\n'
                 'World Coordinate System → Camera Coordinate System', 
                 fontsize=14, fontweight='bold', pad=20)
    
    # 世界坐标系原点
    world_origin = np.array([0, 0, 0])
    draw_coordinate_system(ax, world_origin, size=2, label='_w', colors=['red', 'green', 'blue'])
    
    # 相机位置和朝向
    camera_pos = np.array([3, 3, 3])
    camera_target = np.array([0, 0, 0])
    draw_camera(ax, camera_pos, camera_target, size=2)
    
    # 相机坐标系（在相机位置）
    draw_coordinate_system(ax, camera_pos, size=1.5, label='_c', colors=['darkred', 'darkgreen', 'darkblue'])
    
    # 世界坐标系中的一个3D点
    world_point = np.array([1, 1, 0])
    draw_3d_point(ax, world_point, 'P_w\n(世界坐标)', color='purple')
    
    # 转换到相机坐标系（简化计算）
    # 实际上应该用外参矩阵 [R|t] 进行转换
    # 这里我们手动计算一个示例
    R = np.array([[-0.707, 0.707, 0],
                  [-0.408, -0.408, 0.816],
                  [0.577, 0.577, 0.577]])
    t = np.array([-4.242, -4.242, -5.196])
    camera_point = R @ world_point + t
    draw_3d_point(ax, camera_point, 'P_c\n(相机坐标)', color='magenta', size=80)
    
    # 绘制转换关系线
    draw_projection_line(ax, world_point, camera_point, color='purple', linestyle=':')
    
    # 添加说明文字
    ax.text2D(0.02, 0.98, '外参 [R|t]: 旋转 + 平移', transform=ax.transAxes, 
              fontsize=11, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    ax.text2D(0.02, 0.93, 'P_c = R·P_w + t', transform=ax.transAxes, 
              fontsize=11, bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))
    
    # 设置坐标轴范围
    ax.set_xlim(-1, 4)
    ax.set_ylim(-1, 4)
    ax.set_zlim(-1, 4)
    ax.set_xlabel('X', fontsize=10)
    ax.set_ylabel('Y', fontsize=10)
    ax.set_zlabel('Z', fontsize=10)
    
    # 调整视角
    ax.view_init(elev=20, azim=45)
    
    plt.tight_layout()
    plt.savefig('/Users/zz/work/cppdemo/camera_calibration_step1.png', dpi=150, bbox_inches='tight')
    print("✓ 已生成步骤1可视化图: camera_calibration_step1.png")
    plt.close()

def visualize_camera_to_normalized():
    """可视化：相机坐标系 → 归一化图像平面"""
    fig = plt.figure(figsize=(14, 10))
    ax = fig.add_subplot(111, projection='3d')
    
    # 设置标题
    ax.set_title('步骤2: 相机坐标系 → 归一化图像平面\n'
                 'Camera Coordinate System → Normalized Image Plane', 
                 fontsize=14, fontweight='bold', pad=20)
    
    # 相机坐标系
    camera_origin = np.array([0, 0, 0])
    draw_coordinate_system(ax, camera_origin, size=2, label='_c', colors=['red', 'green', 'blue'])
    
    # 绘制相机光心
    ax.scatter([0], [0], [0], color='orange', s=150, marker='^', label='相机光心')
    
    # 相机坐标系中的3D点
    camera_point = np.array([1, 1, 2])
    draw_3d_point(ax, camera_point, 'P_c\n(相机坐标)', color='purple')
    
    # 归一化图像平面（Z=1）
    z_plane = 1
    xx, yy = np.meshgrid(np.linspace(-1.5, 1.5, 10), np.linspace(-1.5, 1.5, 10))
    zz = np.full_like(xx, z_plane)
    ax.plot_surface(xx, yy, zz, alpha=0.3, color='cyan', label='归一化图像平面')
    
    # 透视投影点
    x_norm = camera_point[0] / camera_point[2]
    y_norm = camera_point[1] / camera_point[2]
    normalized_point = np.array([x_norm, y_norm, z_plane])
    draw_3d_point(ax, normalized_point, 'P_norm\n(归一化坐标)', color='green', size=80)
    
    # 绘制投影线（从相机光心到3D点，再延伸到归一化平面）
    draw_projection_line(ax, camera_origin, camera_point, color='purple', linestyle='--')
    draw_projection_line(ax, camera_origin, normalized_point, color='green', linestyle=':')
    
    # 绘制Z轴延长线
    draw_projection_line(ax, camera_point, normalized_point, color='gray', linestyle='-.')
    
    # 添加说明文字
    ax.text2D(0.02, 0.98, '透视投影: x = X_c/Z_c, y = Y_c/Z_c', transform=ax.transAxes, 
              fontsize=11, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    ax.text2D(0.02, 0.93, '归一化平面位于 Z=1 处', transform=ax.transAxes, 
              fontsize=11, bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))
    ax.text2D(0.02, 0.88, f'示例: ({x_norm:.2f}, {y_norm:.2f}, 1)', transform=ax.transAxes, 
              fontsize=11, bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
    
    # 设置坐标轴范围
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_zlim(0, 3)
    ax.set_xlabel('X_c', fontsize=10)
    ax.set_ylabel('Y_c', fontsize=10)
    ax.set_zlabel('Z_c', fontsize=10)
    
    # 调整视角
    ax.view_init(elev=15, azim=30)
    
    plt.tight_layout()
    plt.savefig('/Users/zz/work/cppdemo/camera_calibration_step2.png', dpi=150, bbox_inches='tight')
    print("✓ 已生成步骤2可视化图: camera_calibration_step2.png")
    plt.close()

def visualize_distortion():
    """可视化：归一化图像平面 → 畸变图像平面"""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # 左图：无畸变
    ax1 = axes[0]
    ax1.set_title('归一化图像平面 (无畸变)\nNormalized Image Plane (No Distortion)', 
                  fontsize=12, fontweight='bold')
    
    # 创建网格点
    x = np.linspace(-1.5, 1.5, 20)
    y = np.linspace(-1.5, 1.5, 20)
    X, Y = np.meshgrid(x, y)
    
    # 绘制网格
    ax1.plot(X, Y, 'b-', alpha=0.5, linewidth=0.5)
    ax1.plot(X.T, Y.T, 'b-', alpha=0.5, linewidth=0.5)
    
    # 绘制一个点
    point = np.array([0.8, 0.6])
    ax1.scatter([point[0]], [point[1]], color='purple', s=100, marker='o', 
                edgecolors='black', linewidths=2, label='P_norm')
    ax1.text(point[0], point[1]+0.1, f'({point[0]:.1f}, {point[1]:.1f})', 
             fontsize=10, fontweight='bold')
    
    # 绘制光心
    ax1.scatter([0], [0], color='orange', s=150, marker='+', linewidths=3, label='光心')
    
    ax1.set_xlim(-1.6, 1.6)
    ax1.set_ylim(-1.6, 1.6)
    ax1.set_xlabel('x', fontsize=10)
    ax1.set_ylabel('y', fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.legend(loc='upper right')
    ax1.set_aspect('equal')
    
    # 右图：有畸变
    ax2 = axes[1]
    ax2.set_title('畸变图像平面 (有畸变)\nDistorted Image Plane (With Distortion)', 
                  fontsize=12, fontweight='bold')
    
    # 模拟畸变（桶形畸变）
    k1 = 0.3  # 径向畸变系数
    R2 = X**2 + Y**2
    X_distorted = X * (1 + k1 * R2)
    Y_distorted = Y * (1 + k1 * R2)
    
    # 绘制畸变后的网格
    ax2.plot(X_distorted, Y_distorted, 'r-', alpha=0.5, linewidth=0.5)
    ax2.plot(X_distorted.T, Y_distorted.T, 'r-', alpha=0.5, linewidth=0.5)
    
    # 畸变后的点
    r2 = point[0]**2 + point[1]**2
    point_distorted = point * (1 + k1 * r2)
    ax2.scatter([point_distorted[0]], [point_distorted[1]], color='magenta', s=100, 
                marker='o', edgecolors='black', linewidths=2, label='P_distorted')
    ax2.text(point_distorted[0], point_distorted[1]+0.1, 
             f'({point_distorted[0]:.1f}, {point_distorted[1]:.1f})', 
             fontsize=10, fontweight='bold')
    
    # 绘制光心
    ax2.scatter([0], [0], color='orange', s=150, marker='+', linewidths=3, label='光心')
    
    # 绘制畸变向量
    ax2.arrow(point[0], point[1], 
              point_distorted[0]-point[0], point_distorted[1]-point[1],
              head_width=0.1, head_length=0.1, fc='purple', ec='purple', 
              linestyle='--', alpha=0.7, label='畸变偏移')
    
    ax2.set_xlim(-1.6, 1.6)
    ax2.set_ylim(-1.6, 1.6)
    ax2.set_xlabel("x'", fontsize=10)
    ax2.set_ylabel("y'", fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.legend(loc='upper right')
    ax2.set_aspect('equal')
    
    # 添加说明文字
    fig.text(0.5, 0.02, 
             '径向畸变公式: x\' = x(1 + k₁r² + k₂r⁴ + k₃r⁶)\n'
             '桶形畸变 (k₁ > 0): 图像边缘向外膨胀 | 枕形畸变 (k₁ < 0): 图像边缘向内收缩',
             ha='center', fontsize=11, 
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    plt.tight_layout(rect=[0, 0.08, 1, 1])
    plt.savefig('/Users/zz/work/cppdemo/camera_calibration_step3.png', dpi=150, bbox_inches='tight')
    print("✓ 已生成步骤3可视化图: camera_calibration_step3.png")
    plt.close()

def visualize_normalized_to_pixel():
    """可视化：归一化图像平面 → 像素坐标系"""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # 左图：归一化图像平面（物理单位：米）
    ax1 = axes[0]
    ax1.set_title('归一化图像平面 (单位: 米)\nNormalized Image Plane (Unit: meters)', 
                  fontsize=12, fontweight='bold')
    
    # 绘制归一化坐标系
    ax1.axhline(y=0, color='k', linestyle='-', linewidth=1, alpha=0.5)
    ax1.axvline(x=0, color='k', linestyle='-', linewidth=1, alpha=0.5)
    
    # 绘制一个点
    norm_point = np.array([0.5, 0.4])
    ax1.scatter([norm_point[0]], [norm_point[1]], color='green', s=100, marker='o', 
                edgecolors='black', linewidths=2, label='P_norm')
    ax1.text(norm_point[0], norm_point[1]+0.05, f'({norm_point[0]:.1f}m, {norm_point[1]:.1f}m)', 
             fontsize=10, fontweight='bold')
    
    ax1.set_xlim(-1, 1)
    ax1.set_ylim(-1, 1)
    ax1.set_xlabel('x (米)', fontsize=10)
    ax1.set_ylabel('y (米)', fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.legend(loc='upper right')
    ax1.set_aspect('equal')
    
    # 右图：像素坐标系（单位：像素）
    ax2 = axes[1]
    ax2.set_title('像素坐标系 (单位: 像素)\nPixel Coordinate System (Unit: pixels)', 
                  fontsize=12, fontweight='bold')
    
    # 相机内参（示例）
    fx = 800  # 像素
    fy = 800  # 像素
    cx = 640  # 像素（图像中心）
    cy = 480  # 像素（图像中心）
    
    # 转换到像素坐标
    u = fx * norm_point[0] + cx
    v = fy * norm_point[1] + cy
    pixel_point = np.array([u, v])
    
    # 绘制图像边界
    image_width = 1280
    image_height = 960
    rect = Rectangle((0, 0), image_width, image_height, 
                     linewidth=2, edgecolor='blue', facecolor='lightgray', alpha=0.3)
    ax2.add_patch(rect)
    
    # 绘制主点（光心在图像上的投影）
    ax2.scatter([cx], [cy], color='orange', s=150, marker='+', linewidths=3, 
                label=f'主点 (c_x={cx}, c_y={cy})')
    
    # 绘制像素点
    ax2.scatter([pixel_point[0]], [pixel_point[1]], color='red', s=100, marker='o', 
                edgecolors='black', linewidths=2, label='p(u,v)')
    ax2.text(pixel_point[0], pixel_point[1]+30, 
             f'({pixel_point[0]:.0f}, {pixel_point[1]:.0f})', 
             fontsize=10, fontweight='bold')
    
    # 绘制转换箭头
    ax2.annotate('', xy=(pixel_point[0], pixel_point[1]), 
                 xytext=(cx, cy),
                 arrowprops=dict(arrowstyle='->', lw=2, color='purple'),
                 bbox=dict(boxstyle='round,pad=0.5', fc='yellow', alpha=0.5))
    
    ax2.set_xlim(-100, image_width + 100)
    ax2.set_ylim(image_height + 100, -100)  # Y轴向下
    ax2.set_xlabel('u (像素)', fontsize=10)
    ax2.set_ylabel('v (像素)', fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.legend(loc='upper right')
    ax2.set_aspect('equal')
    
    # 添加说明文字
    fig.text(0.5, 0.02, 
             f'内参矩阵 K:\n'
             f'┌  {fx}   0   {cx} ┐\n'
             f'│   0   {fy}  {cy} │\n'
             f'└   0    0    1  ┘\n\n'
             f'转换公式: u = f_x·x + c_x,  v = f_y·y + c_y\n'
             f'示例: u = {fx}×{norm_point[0]:.1f} + {cx} = {pixel_point[0]:.0f}\n'
             f'      v = {fy}×{norm_point[1]:.1f} + {cy} = {pixel_point[1]:.0f}',
             ha='center', fontsize=10, family='monospace',
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    plt.tight_layout(rect=[0, 0.15, 1, 1])
    plt.savefig('/Users/zz/work/cppdemo/camera_calibration_step4.png', dpi=150, bbox_inches='tight')
    print("✓ 已生成步骤4可视化图: camera_calibration_step4.png")
    plt.close()

def visualize_complete_pipeline():
    """可视化完整的转换流程"""
    fig = plt.figure(figsize=(20, 12))
    
    # 创建4个子图
    gs = fig.add_gridspec(2, 2, hspace=0.3, wspace=0.3)
    
    # 子图1: 世界坐标系 → 相机坐标系
    ax1 = fig.add_subplot(gs[0, 0], projection='3d')
    ax1.set_title('1. 世界 → 相机\nWorld → Camera', fontsize=11, fontweight='bold')
    
    # 简化绘制
    draw_coordinate_system(ax1, [0, 0, 0], size=1.5, label='_w', colors=['red', 'green', 'blue'])
    draw_coordinate_system(ax1, [2, 2, 2], size=1, label='_c', colors=['darkred', 'darkgreen', 'darkblue'])
    draw_3d_point(ax1, [1, 0, 0], 'P_w', color='purple')
    draw_3d_point(ax1, [2.5, 2, 2], 'P_c', color='magenta', size=80)
    ax1.set_xlim(-1, 3)
    ax1.set_ylim(-1, 3)
    ax1.set_zlim(-1, 3)
    ax1.view_init(elev=20, azim=45)
    
    # 子图2: 相机坐标系 → 归一化图像平面
    ax2 = fig.add_subplot(gs[0, 1], projection='3d')
    ax2.set_title('2. 相机 → 归一化平面\nCamera → Normalized', fontsize=11, fontweight='bold')
    
    draw_coordinate_system(ax2, [0, 0, 0], size=1.5, label='_c', colors=['red', 'green', 'blue'])
    ax2.scatter([0], [0], [0], color='orange', s=100, marker='^')
    draw_3d_point(ax2, [0.5, 0.5, 1.5], 'P_c', color='purple')
    draw_3d_point(ax2, [0.33, 0.33, 1], 'P_norm', color='green', size=80)
    draw_projection_line(ax2, [0, 0, 0], [0.33, 0.33, 1], color='green', linestyle=':')
    ax2.set_xlim(-1, 1)
    ax2.set_ylim(-1, 1)
    ax2.set_zlim(0, 2)
    ax2.view_init(elev=15, azim=30)
    
    # 子图3: 归一化平面 → 畸变平面
    ax3 = fig.add_subplot(gs[1, 0])
    ax3.set_title('3. 归一化 → 畸变\nNormalized → Distorted', fontsize=11, fontweight='bold')
    
    x = np.linspace(-1, 1, 15)
    y = np.linspace(-1, 1, 15)
    X, Y = np.meshgrid(x, y)
    
    # 无畸变网格
    ax3.plot(X, Y, 'b-', alpha=0.5, linewidth=0.5)
    ax3.plot(X.T, Y.T, 'b-', alpha=0.5, linewidth=0.5)
    ax3.scatter([0.5], [0.4], color='green', s=80, marker='o', label='P_norm')
    
    # 畸变网格（叠加）
    k1 = 0.2
    R2 = X**2 + Y**2
    X_dist = X * (1 + k1 * R2)
    Y_dist = Y * (1 + k1 * R2)
    ax3.plot(X_dist, Y_dist, 'r-', alpha=0.5, linewidth=0.5)
    ax3.plot(X_dist.T, Y_dist.T, 'r-', alpha=0.5, linewidth=0.5)
    
    r2 = 0.5**2 + 0.4**2
    point_dist = np.array([0.5, 0.4]) * (1 + k1 * r2)
    ax3.scatter([point_dist[0]], [point_dist[1]], color='magenta', s=80, 
                marker='o', label="P_distorted")
    ax3.arrow(0.5, 0.4, point_dist[0]-0.5, point_dist[1]-0.4,
              head_width=0.08, head_length=0.08, fc='purple', ec='purple', 
              linestyle='--', alpha=0.7)
    
    ax3.set_xlim(-1.2, 1.2)
    ax3.set_ylim(-1.2, 1.2)
    ax3.set_xlabel('x')
    ax3.set_ylabel('y')
    ax3.grid(True, alpha=0.3)
    ax3.legend()
    ax3.set_aspect('equal')
    
    # 子图4: 归一化平面 → 像素坐标
    ax4 = fig.add_subplot(gs[1, 1])
    ax4.set_title('4. 归一化 → 像素\nNormalized → Pixel', fontsize=11, fontweight='bold')
    
    # 绘制图像
    rect = Rectangle((0, 0), 640, 480, linewidth=2, edgecolor='blue', 
                     facecolor='lightgray', alpha=0.3)
    ax4.add_patch(rect)
    
    # 主点
    cx, cy = 320, 240
    ax4.scatter([cx], [cy], color='orange', s=100, marker='+', linewidths=3, 
                label='主点')
    
    # 像素点
    fx, fy = 400, 400
    u = fx * 0.5 + cx
    v = fy * 0.4 + cy
    ax4.scatter([u], [v], color='red', s=80, marker='o', 
                edgecolors='black', linewidths=2, label='p(u,v)')
    ax4.text(u, v+15, f'({u:.0f}, {v:.0f})', fontsize=9, fontweight='bold')
    
    ax4.set_xlim(-50, 690)
    ax4.set_ylim(530, -50)
    ax4.set_xlabel('u (像素)')
    ax4.set_ylabel('v (像素)')
    ax4.grid(True, alpha=0.3)
    ax4.legend()
    ax4.set_aspect('equal')
    
    # 添加整体说明
    fig.suptitle('相机标定完整流程可视化\nComplete Camera Calibration Pipeline Visualization', 
                 fontsize=14, fontweight='bold', y=0.98)
    
    plt.savefig('/Users/zz/work/cppdemo/camera_calibration_complete.png', dpi=150, bbox_inches='tight')
    print("✓ 已生成完整流程可视化图: camera_calibration_complete.png")
    plt.close()

def create_summary_diagram():
    """创建总结图"""
    fig, ax = plt.subplots(figsize=(16, 8))
    ax.set_title('相机标定坐标系转换总结\nSummary of Camera Calibration Coordinate Transformations', 
                 fontsize=14, fontweight='bold', pad=20)
    
    # 绘制流程图
    stages = [
        ('世界坐标系\nWorld Coordinate\nP_w = (X_w, Y_w, Z_w)', 
         '外参 [R|t]\n旋转 + 平移\nP_c = R·P_w + t'),
        ('相机坐标系\nCamera Coordinate\nP_c = (X_c, Y_c, Z_c)', 
         '透视投影\nx = X_c/Z_c\ny = Y_c/Z_c'),
        ('归一化图像平面\nNormalized Plane\nP_norm = (x, y, 1)', 
         '畸变模型\n径向 + 切向\nP_distorted'),
        ('畸变图像平面\nDistorted Plane\nP_distorted = (x\', y\')', 
         '内参矩阵 K\n焦距 + 主点\np(u,v)'),
        ('像素坐标系\nPixel Coordinate\np = (u, v)', 
         '最终结果\n图像像素位置')
    ]
    
    # 绘制阶段框
    box_width = 2.5
    box_height = 1.5
    y_pos = 2
    
    for i, (title, formula) in enumerate(stages):
        x_pos = i * 3.5 + 1
        
        # 绘制方框
        rect = Rectangle((x_pos - box_width/2, y_pos - box_height/2), 
                        box_width, box_height,
                        linewidth=2, edgecolor='blue', facecolor='lightblue', alpha=0.7)
        ax.add_patch(rect)
        
        # 添加文字
        ax.text(x_pos, y_pos + 0.3, title, ha='center', va='center', 
                fontsize=10, fontweight='bold')
        ax.text(x_pos, y_pos - 0.3, formula, ha='center', va='center', 
                fontsize=9, family='monospace')
        
        # 绘制箭头
        if i < len(stages) - 1:
            ax.arrow(x_pos + box_width/2, y_pos, 
                    3.5 - box_width, 0,
                    head_width=0.2, head_length=0.2, fc='red', ec='red',
                    linewidth=2)
    
    # 添加参数说明
    param_text = (
        '关键参数说明:\n'
        '• 外参 [R|t]: 相机在世界中的位置和朝向\n'
        '• 内参 K: 焦距(f_x, f_y)、主点(c_x, c_y)、像素偏斜(s)\n'
        '• 畸变系数: 径向(k₁, k₂, k₃)、切向(p₁, p₂)\n\n'
        '标定目标: 已知P_w和p(u,v)，求解K、畸变系数和[R|t]'
    )
    
    ax.text(8.5, 0, param_text, ha='center', va='center', fontsize=11,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    ax.set_xlim(-1, 18)
    ax.set_ylim(-1.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('/Users/zz/work/cppdemo/camera_calibration_summary.png', dpi=150, bbox_inches='tight')
    print("✓ 已生成总结图: camera_calibration_summary.png")
    plt.close()

if __name__ == '__main__':
    print("=" * 60)
    print("开始生成相机标定可视化图表...")
    print("=" * 60)
    
    # 生成各个步骤的可视化
    visualize_world_to_camera()
    visualize_camera_to_normalized()
    visualize_distortion()
    visualize_normalized_to_pixel()
    visualize_complete_pipeline()
    create_summary_diagram()
    
    print("=" * 60)
    print("✓ 所有可视化图表生成完成！")
    print("=" * 60)
    print("\n生成的文件:")
    print("1. camera_calibration_step1.png - 世界坐标系 → 相机坐标系")
    print("2. camera_calibration_step2.png - 相机坐标系 → 归一化图像平面")
    print("3. camera_calibration_step3.png - 归一化图像平面 → 畸变图像平面")
    print("4. camera_calibration_step4.png - 归一化图像平面 → 像素坐标系")
    print("5. camera_calibration_complete.png - 完整流程可视化")
    print("6. camera_calibration_summary.png - 总结图")
    print("\n请打开这些图片查看详细的可视化说明！")
