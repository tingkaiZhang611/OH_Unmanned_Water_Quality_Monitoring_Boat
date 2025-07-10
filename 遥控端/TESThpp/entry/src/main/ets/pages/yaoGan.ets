export interface yaoGanPostion {
  x: number;
  y: number;
}

@Component
export struct JoystickComponent {
  @State joystickPos: yaoGanPostion = { x: 0, y: 0 }
  @Link normalizedX: number;
  @Link normalizedY: number;
  @Link direction1: number; // 新增：方向值绑定
  private bgRadius: number = 100
  private stickRadius: number = 30
  private maxDistance: number = this.bgRadius - this.stickRadius
  centerX: number = this.bgRadius
  centerY: number = this.bgRadius

  // 新增：计算方向区域 (1,2,3,4)
  private calculateDirection(x: number, y: number): number {
    if (x === 0 && y === 0) return 0; // 中心点无方向

    // 根据坐标位置判断方向区域
    if (y <= x && y >= -x) return 1; // 右侧区域
    if (y >= x && y >= -x) return 2; // 下方区域
    if (y >= x && y <= -x) return 3; // 左侧区域
    return 4; // 上方区域
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(this.bgRadius * 2)
        .height(this.bgRadius * 2)
        .fill(Color.Black)
        .opacity(0.5)
        .onAreaChange((_oldValue, newValue) => {
          const width = Number(newValue.width);
          const height = Number(newValue.height);
          this.centerX = width / 2;
          this.centerY = height / 2;
        })

      Circle()
        .width(this.stickRadius * 2)
        .height(this.stickRadius * 2)
        .fill('#ffa1a1a1')
        .stroke('#803b3b3b')
        .position({
          x: this.joystickPos.x + this.centerX - this.stickRadius,
          y: this.joystickPos.y + this.centerY - this.stickRadius
        })
        .gesture(
          PanGesture()
            .onActionUpdate((event: GestureEvent) => {
              let dx = event.offsetX
              let dy = event.offsetY
              const distance = Math.sqrt(dx * dx + dy * dy)

              if (distance > this.maxDistance) {
                dx = dx * this.maxDistance / distance
                dy = dy * this.maxDistance / distance
              }

              this.joystickPos = { x: dx, y: dy }
              this.normalizedX = dx / this.maxDistance
              this.normalizedY = dy / this.maxDistance

              // 新增：计算并更新方向值
              this.direction1 = this.calculateDirection(this.normalizedX, this.normalizedY);
            })
            .onActionEnd(() => {
              this.joystickPos = { x: 0, y: 0 }
              this.normalizedX = 0;
              this.normalizedY = 0;
              this.direction1 = 0; // 重置方向
            })
        )
    }
    .width(this.bgRadius * 2)
    .height(this.bgRadius * 2)
  }
}