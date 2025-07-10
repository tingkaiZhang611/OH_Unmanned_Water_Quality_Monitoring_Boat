interface X{
  x: number;
  width: number;
}
interface Y{
  x: number;
  y: number;
  height: number;
}

@Component
export struct SpeedSelecter{
  private speeds: string[] = ['x0.25', 'x0.5', 'x0.75', 'x1'];
  @State selectedSpeed: string = 'x1';
  @State isPopupVisible: boolean = false;
  @State popupRect: X = { x: 0, width: 0 };
  @State buttonRect: Y = { x:0, y: 0, height: 0 };

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Button(this.selectedSpeed)
        .width(100)
        .height(100)
        .borderRadius(50)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#fff0f0f0')
        .backgroundColor('#80000000')
        .onAreaChange((oldVal, newVal) => {
          this.buttonRect.x = Number(newVal.globalPosition.x);
          this.buttonRect.y = Number(newVal.globalPosition.y);
          this.buttonRect.height = Number(newVal.height);
        })
        .position({
          x:0,y:0
        })
        .onTouch((event: TouchEvent) => {
          switch (event.type) {
            case TouchType.Down:
              this.isPopupVisible = true;
              break;
            case TouchType.Move:
              if (this.isPopupVisible && this.popupRect.width > 0) {
                const touchX = event.touches[0].windowX;
                const relativeX = touchX - this.popupRect.x;
                const index = Math.floor((relativeX / this.popupRect.width) * this.speeds.length);
                if (index >= 0 && index < this.speeds.length) {
                  this.selectedSpeed = this.speeds[index];
                }
              }
              break;
            case TouchType.Up:
              this.isPopupVisible = false;
              break;
          }
        })
        .position({
          x:0,
          y:0
        })
      if (this.isPopupVisible) {
        Row(){
          ForEach(this.speeds, (speed:string) => {
            Text(speed)
              .flexGrow(1)
              .textAlign(TextAlign.Center)
              .fontColor(this.selectedSpeed === speed ? '#fffb7299' : '#ffdfdfdf')
              .fontWeight(FontWeight.Bold)
              .fontSize(24)
          })
        }
          .padding({top:8,bottom:8,left:3,right:3})
          .width(this.buttonRect.height*3)
          .height(50)
          .backgroundColor('#80000000')
          .borderRadius(10)
          .shadow({ radius: 8, color: '#999', offsetX: 2, offsetY: 2 })
          .position({
            x: 0-this.popupRect.width + this.buttonRect.height,
            y: 0-this.buttonRect.height*0.65
          })
          .onAreaChange((oldVal, newVal) => {
            this.popupRect.x = Number(newVal.globalPosition.x);
            this.popupRect.width = Number(newVal.width);
          })
      }
    }
    .width(100)
    .height(100)
    .clip(false)
  }
}