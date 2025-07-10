import { YaoKong } from '../pages/YaoKong';
import { ECMonitor } from './OHppTabs';
import { IoTContent } from './IoTContent';
import { testUpper } from './testUpper';

@Entry
@Preview
@Component
struct Index {
  private barManager:TabsController=new TabsController();
  @State private selected:number=0;
  @Builder
  ShuJu(title:string,index:number,defaultImg:string|Resource,hotImg:string|Resource){
    Column(){
      Image(this.selected!=index?defaultImg:hotImg)
        .width('70%')

      Text(title)
        .fontColor(this.selected!=index?'#ff4d4d4d':'#ff008fff')
        .margin({top:10})
        .fontSize(20)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .margin(0)
    .onClick(()=>{
      this.selected=index;
      this.barManager.changeIndex(index)
    })

  }

  build() {
    Tabs({barPosition:BarPosition.Start,controller:this.barManager}){
      TabContent(){
        IoTContent();
      }.tabBar(this.ShuJu('设备管理',0,$r("app.media.chanPin"),$r("app.media.chanPin")))

      TabContent(){
        YaoKong();
      }.tabBar(this.ShuJu('设备云控',1,$r("app.media.yunDuan"),$r("app.media.yunDuan")))

      TabContent(){
        ECMonitor();
      }.tabBar(this.ShuJu('数据采集',2,$r("app.media.shuJuCaiJi"),$r("app.media.shuJuCaiJi")))

      TabContent(){
        testUpper();
      }.tabBar(this.ShuJu('应用设置',3,$r("app.media.sheZhi"),$r("app.media.sheZhi")))
    }
    .vertical(true)
    .scrollable(false)
    .padding(16)
  }
}