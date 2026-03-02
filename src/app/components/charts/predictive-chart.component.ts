import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-predictive-chart',
  templateUrl: './predictive-chart.component.html',
  styleUrls: ['./predictive-chart.component.scss']
})
export class PredictiveChartComponent implements OnInit {
  public chartOptions: any;

  constructor() {
    this.chartOptions = {
      series: [
        {
          name: "Datos Históricos",
          data: this.generateHistoricalData()
        },
        {
          name: "Predicción",
          data: this.generatePredictionData()
        }
      ],
      chart: {
        height: 350,
        type: "line"
      },
      title: {
        text: "Análisis Predictivo de Productos",
        align: "left"
      },
      xaxis: {
        categories: this.generateWeekLabels()
      }
    };
  }

  ngOnInit(): void {}

  private generateHistoricalData(): number[] {
    return Array.from({ length: 12 }, (_, i) => 
      Math.floor(Math.random() * 500) + 200 + i * 20
    );
  }

  private generatePredictionData(): number[] {
    return Array.from({ length: 16 }, (_, i) => 
      Math.floor(Math.random() * 600) + 300 + i * 25
    );
  }

  private generateWeekLabels(): string[] {
    const historical = Array.from({ length: 12 }, (_, i) => `S${i + 1}`);
    const prediction = Array.from({ length: 16 }, (_, i) => `S${i + 13}`);
    return [...historical, ...prediction];
  }
}