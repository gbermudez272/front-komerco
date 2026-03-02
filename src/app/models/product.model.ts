export interface Product {
  id: string;
  name: string;
  category: string;
  currentStock: number;
  weeklyDemand: number;
  price: number;
  historicalData: number[];
  prediction: number[];
  reorderPoint?: number;
  safetyStock?: number;
  leadTime?: number;
  lastOrderDate?: string;
  forecastError?: number;
  confidenceLevel?: number;
}

export interface ChartData {
  categories: string[];
  series: {
    name: string;
    data: number[];
    color?: string;
  }[];
}