import { faceDetector } from "@kit.CoreVisionKit"
import document from "@ohos.document";

@Component
export struct IoTContent{
  @State isContented:boolean=false;
  @State type:boolean=false;
  @State text:string='基于开源鸿蒙的无人水质监测船';
  @State img:Resource=$r('app.media.zhankai');
  @State imgSize:string='70%';
  build() {
    Column(){
      Text('设备连接中心')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
      Row(){
        Image($r('app.media.tops'))
          .height('70%')
          .margin({left:15,right:15})
        Text('扫描设备中...')
          .fontSize(18)
          .fontColor('#ff1f92ec')
      }
      .height('8%')
      .width('60%')
      .padding(10)
      .margin(20)
      .backgroundColor("#ffe2f2ff")
      .border({width:1,color:"#ff138ef0"})
      .borderRadius(26)


      Scroll(){
        Column(){
          Row(){
            Image($r('app.media.foreground'))
              .height('85%')
              .margin({right:15})
            Text(this.text)
              .fontSize(16)
              .fontColor(!this.type? '#ff000000' :'#138EF0')
            Blank()
            Image(this.img)
              .height(this.imgSize)
          }
          .onClick(()=>{

            this.text=this.text+'--连接中';
            this.img=$r('app.media.lianJieZhong');
            this.imgSize='100%';
            let timer = setTimeout(()=> {
              this.text='基于开源鸿蒙的无人水质监测船--已连接';
              this.imgSize='70%';
              this.type=true;
              this.img=$r('app.media.contented');
            }, 3500);
          })
          .height('10%')
          .width('80%')
          .padding(10)
          .borderRadius(30)
          .border({width:1,color:!this.type? "#bf797979" :"#138EF0"})
          .shadow({ radius: 8, color: '#e0e0e0', offsetX: 0, offsetY: 4 })
        }
      }
      .width('100%')
      .height('100%')
      .padding(20)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }
}