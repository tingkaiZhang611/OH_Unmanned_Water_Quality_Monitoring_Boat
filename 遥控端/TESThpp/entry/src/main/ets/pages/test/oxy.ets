import { hmChart, ChartOptions, hmChartType } from "@wuyan/hm_chart";

// 核心类型定义保持不变
interface ChartAxisLineStyle {
  color: string;
}

interface ChartAxisLabel {
  color: string;
  formatter?: string;
}

interface ChartTextStyle {
  color?: string;
  fontStyle?: 'normal' | 'italic' | 'oblique';
  fontWeight?: string | number;
  fontFamily?: string;
  fontSize?: number;
  lineHeight?: number;
  textBorderColor?: string;
  textBorderWidth?: number;
  textShadowColor?: string;
  textShadowBlur?: number;
  textShadowOffsetX?: number;
  textShadowOffsetY?: number;
}

interface ChartAxisLine {
  lineStyle: ChartAxisLineStyle;
}

interface ChartXAxis {
  type: 'category';
  data: string[];
  axisLine?: ChartAxisLine;
  axisLabel?: ChartAxisLabel;
}

interface ChartYAxis {
  type: 'value';
  min: number;
  max: number;
  splitLine?: ChartAxisLine;
  axisLabel?: ChartAxisLabel;
}

interface ChartGrid {
  left: string;
  right: string;
  bottom: string;
  top: string;
  containLabel: boolean;
}

interface ChartLineStyle {
  width: number;
  color: string;
}

interface ChartItemStyle {
  color: string;
  borderWidth: number;
  borderColor: string;
}

interface ChartColorStop {
  offset: number;
  color: string;
}

interface ChartAreaStyleColor {
  type: 'linear';
  x: number;
  y: number;
  x2: number;
  y2: number;
  colorStops: ChartColorStop[];
}

interface ChartAreaStyle {
  color: ChartAreaStyleColor;
}

interface ChartSeries {
  name: string;
  type: 'line';
  data: number[];
  smooth: boolean;
  symbol?: 'circle';
  symbolSize?: number;
  lineStyle: ChartLineStyle;
  itemStyle: ChartItemStyle;
  areaStyle: ChartAreaStyle;
}

interface ChartTooltipParam {
  axisValue: string;
  data: number;
}

interface ChartTooltip {
  trigger: 'axis';
  backgroundColor: string;
  borderColor: string;
  borderWidth: number;
  padding: number;
  textStyle: ChartTextStyle;
  formatter: (params: ChartTooltipParam[]) => string;
}

// ====================== 主组件实现 ======================
@Entry
@Component
struct DOMonitor {
  @State myChart: hmChartType | null = null;
  @State doValues: number[] = []; // 溶解氧数据数组
  @State timeLabels: string[] = [];
  @State currentDo: number = 0; // 当前溶解氧值
  @State lastDo: number = 7.5; // 新增：记录上一个值，控制波动范围

  // 图表配置适配溶解氧范围（5~10 mg/L）
  private chartOptions: ChartOptions = {
    xAxis: {
      type: 'category',
      data: [],
      axisLine: { lineStyle: { color: '#888' } },
      axisLabel: { color: '#666' }
    },
    yAxis: {
      type: 'value',
      min: 5, // 溶解氧最小值
      max: 10, // 溶解氧最大值
      splitLine: { lineStyle: { color: '#f0f0f0' } },
      axisLabel: { formatter: '{value} mg/L', color: '#666' } // 单位改为mg/L
    },
    grid: {
      left: '5%',
      right: '5%',
      bottom: '10%',
      top: '15%',
      containLabel: true
    },
    series: [
      {
        name: '溶解氧', // 系列名称修改
        type: 'line',
        data: [],
        smooth: true,
        symbol: 'circle',
        symbolSize: 8,
        lineStyle: { width: 3, color: '#36a1ff' },
        itemStyle: { color: '#ffffff', borderWidth: 2, borderColor: '#36a1ff' },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(54, 161, 255, 0.4)' },
              { offset: 1, color: 'rgba(54, 161, 255, 0.1)' }
            ]
          }
        }
      }
    ],
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(255,255,255,0.9)',
      borderColor: '#eee',
      borderWidth: 1,
      padding: 10,
      textStyle: { color: '#333' },
      formatter: (params: ChartTooltipParam[]) =>
      params?.[0] ? `${params[0].axisValue}<br/>溶解氧: ${params[0].data} mg/L` : '' // 提示框文本修改
    }
  };

  private timerId: number | null = null;

  // 生成5~10 mg/L之间的溶解氧值（基于上一个值小范围波动，减少抖动）
  private generateRandomDo(): number {
    const min = 5;
    const max = 10;
    const range = 0.2; // 波动范围±0.2，减小抖动
    // 基于上一个值生成新值，控制波动幅度
    let newValue = this.lastDo + (Math.random() - 0.5) * 2 * range;
    // 确保在有效范围内
    newValue = Math.max(min, Math.min(max, newValue));
    newValue = Number(newValue.toFixed(1)); // 保留1位小数
    this.lastDo = newValue; // 更新上一个值
    return newValue;
  }

  private getCurrentTime(): string {
    const pad = (n: number) => n.toString().padStart(2, '0');
    const now = new Date();
    return `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
  }

  startMonitoring(): void {
    if (this.timerId !== null) return;

    // 延长更新间隔至2秒，减少抖动频率
    this.timerId = setInterval(() => {
      const newDo = this.generateRandomDo();
      const newTime = this.getCurrentTime();

      this.currentDo = newDo;
      this.doValues = [...this.doValues, newDo].slice(-20); // 保留最近20条数据
      this.timeLabels = [...this.timeLabels, newTime].slice(-20);

      // 更新X轴数据
      (this.chartOptions.xAxis as ChartXAxis).data = this.timeLabels;

      // 更新系列数据
      if (Array.isArray(this.chartOptions.series)) {
        const series = this.chartOptions.series as ChartSeries[];
        if (series.length > 0) {
          series[0].data = this.doValues;
        }
      }

      this.myChart?.setOption(this.chartOptions);
    }, 2000) as number; // 从1000ms改为2000ms
  }

  stopMonitoring(): void {
    if (this.timerId !== null) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
  }

  aboutToDisappear(): void {
    this.stopMonitoring();
  }

  build() {
    Column() {
      Text('溶解氧实时监控') // 标题修改
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })
        .fontColor('#333');

      Column() {
        Text('当前溶解氧') // 显示文本修改
          .fontSize(16)
          .fontColor('#666')
          .margin({ bottom: 5 });
        Row() {
          Text(this.currentDo.toString())
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333');
          Text('mg/L') // 单位修改
            .fontSize(24)
            .margin({ left: 5, top: 5 })
            .fontColor('#666');
        }
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#fff')
      .borderRadius(16)
      .shadow({ radius: 8, color: '#e0e0e0', offsetX: 0, offsetY: 4 })
      .margin({ bottom: 20 });

      Stack() {
        hmChart({ Options: this.chartOptions, myChart: $myChart })
          .width('100%')
          .height(300);

        Text('溶解氧变化趋势') // 趋势图标题修改
          .fontSize(16)
          .fontColor('#666')
          .position({ x: '5%', y: '5%' });
      }
      .width('90%')
      .height(300)
      .backgroundColor('#fff')
      .borderRadius(16)
      .shadow({ radius: 8, color: '#e0e0e0', offsetX: 0, offsetY: 4 })
      .margin({ bottom: 20 });

      Row() {
        Button('开始监控')
          .onClick(() => this.startMonitoring())
          .width(120)
          .height(40)
          .backgroundColor('#36a1ff')
          .fontColor('#fff')
          .fontSize(16);
        Button('停止监控')
          .onClick(() => this.stopMonitoring())
          .width(120)
          .height(40)
          .backgroundColor('#ff6b81')
          .fontColor('#fff')
          .fontSize(16)
          .margin({ left: 20 });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f8f9fa')
    .justifyContent(FlexAlign.Center);
  }
}

export { DOMonitor };