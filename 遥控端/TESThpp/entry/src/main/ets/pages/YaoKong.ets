import { PostUtil } from '../Component/Web';
import { JoystickComponent } from '../pages/yaoGan';


@Component
export struct YaoKong {
  @State data: string[] = ['hpp♥🥣🦌', '键入内容以添加...']
  @State Xed: number = 0;
  @State Yed: number = 0;
  @State BaiFen: number = 100;
  @State direction1: number = 0; // 新增：方向状态变量
  private pre:string='中心';
  @State gpsOk:boolean=true;
  poster:PostUtil=new PostUtil();

  build() {
    RelativeContainer() {
      Column() {
        // 修改：添加方向显示
        Text('OpenHarmony无人水质监测船\n\n当前操纵杆坐标' +
          '\n\nX:' + this.Xed.toFixed(2) +
          '\nY:' + this.Yed.toFixed(2) +
          '\n方向:' + this.getDirectionText())
          .fontSize(24)
          .fontColor('#ffffffff')
          .backgroundColor('#ff3590f9')
          .padding(16)
          .borderRadius(10)

        Text(this.gpsOk?'当前GPS坐标：'+'\n经度：115.8379 .°E'+'\n纬度：28.7045 °N':'当前GPS坐标：'+'\n经度：115.**** °E'+'\n纬度：28.**** °N')
          .fontSize(24)
          .width('60%')
          .fontColor('#138EF0')
          .backgroundColor('#ffe2f2ff')
          .borderRadius(30)
          .border({width:1,color:"#138EF0"})
          .padding(16)
          .borderRadius(10)
          .margin({top:20})

        Button(this.gpsOk?'关闭GPS精确显示':'打开GPS精确显示')
          .fontSize(16)
          .margin({top:10})
          .onClick(()=>{
            this.gpsOk=!this.gpsOk;
          })

        // 修改：添加方向绑定
        JoystickComponent({
          normalizedX: this.Xed,
          normalizedY: this.Yed,
          direction1: this.direction1
        })
          .position({ bottom: 15, left: 15 })
      }
      .height('100%')
      .width('100%')

      Row() {
        Text(this.BaiFen + '%')
          .lineHeight(50)
          .rotate({ angle: -90 })
          .padding(0)
        Slider({
          value: $$this.BaiFen,
          direction: Axis.Vertical,
          style: SliderStyle.InSet,
          step: 25,
          reverse: true
        })
          .showSteps(true)
          .selectedColor('#fffb7299')
          .height('50%')
          .align(Alignment.Center)
      }
      .position({ bottom: 10, right: 3 })
    }
  }

  // 新增：将数字方向转换为文字
  private getDirectionText(): string {
    switch (this.direction1) {
      case 1: {
        if('right'!=this.pre){
          this.pre='right';
          //下发设备
          this.poster.postUpper("[ORDER]right")
        }
        return 'right'
      };
      case 2: {
        if('under'!=this.pre){
          this.pre='under';
          //下发设备
          this.poster.postUpper("[ORDER]under")
        }

        return 'under'
      };
      case 3: {
        if('left'!=this.pre){
          this.pre='left';
          //下发设备
          this.poster.postUpper("[ORDER]left")
        }

        return 'left'
      };
      case 4: {
        if('up'!=this.pre){
          this.pre='up';
          //下发设备
          this.poster.postUpper("[ORDER]up")
        }

        return 'up'
      };
      default: {
        if('centen'!=this.pre){
          this.pre='centen';
          //下发设备
          this.poster.postUpper("[ORDER]centen")
        }

        return 'centen'
      };
    }
  }
}