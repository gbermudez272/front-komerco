import { Component, Input } from '@angular/core';
import { Product } from '../../models/product.model';

@Component({
  selector: 'app-product-card',
  templateUrl: './product-card.component.html',
  styleUrls: ['./product-card.component.scss']
})
export class ProductCardComponent {
  @Input() product: Product | null = null;
  @Input() showAnalysis: boolean = false;

  getStockStatus(): { text: string, color: string } {
    if (!this.product) return { text: 'Desconocido', color: 'gray' };
    
    const stockRatio = this.product.currentStock / this.product.weeklyDemand;
    
    if (stockRatio < 1) {
      return { text: 'Crítico', color: 'error' };
    } else if (stockRatio < 2) {
      return { text: 'Bajo', color: 'warning' };
    } else if (stockRatio < 4) {
      return { text: 'Adecuado', color: 'success' };
    } else {
      return { text: 'Excedente', color: 'info' };
    }
  }

  getDemandTrend(): { text: string, icon: string, color: string } {
    if (!this.product || !this.product.historicalData || this.product.historicalData.length < 2) {
      return { text: 'Estable', icon: 'trending_flat', color: 'gray' };
    }
    
    const last = this.product.historicalData[this.product.historicalData.length - 1];
    const previous = this.product.historicalData[this.product.historicalData.length - 2];
    const change = ((last - previous) / previous) * 100;
    
    if (change > 10) {
      return { text: 'Alta', icon: 'trending_up', color: 'error' };
    } else if (change > 5) {
      return { text: 'Moderada', icon: 'trending_up', color: 'warning' };
    } else if (change < -10) {
      return { text: 'Baja', icon: 'trending_down', color: 'success' };
    } else if (change < -5) {
      return { text: 'Decreciente', icon: 'trending_down', color: 'info' };
    } else {
      return { text: 'Estable', icon: 'trending_flat', color: 'gray' };
    }
  }
}
