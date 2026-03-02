import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { Product } from '../models/product.model';

// Interfaz CSVProduct actualizada
export interface CSVProduct {
  upc: string;
  codigoWM2: string;
  itemFlags: string;
  descripcion: string;
  category?: string;
  cleanName?: string;
}

export interface HighlightedPrediction {
  productId: string;
  productName: string;
  currentDemand: number;
  predictedDemand: number;
  changePercent: number;
  confidence: number;
  riskLevel: 'low' | 'medium' | 'high';
  recommendation?: string;
}

@Injectable({
  providedIn: 'root'
})
export class DataService {
  private productsSubject = new BehaviorSubject<Product[]>([]);
  private csvProductsSubject = new BehaviorSubject<CSVProduct[]>([]);
  
  products$: Observable<Product[]> = this.productsSubject.asObservable();
  csvProducts$: Observable<CSVProduct[]> = this.csvProductsSubject.asObservable();

  constructor() {
    this.loadMockData();
  }

  private loadMockData(): void {
    const mockProducts: Product[] = [
      {
        id: 'PROD-001',
        name: 'Cuaderno Profesional A4',
        category: 'Escritura',
        currentStock: 1250,
        weeklyDemand: 320,
        price: 15.99,
        historicalData: this.generateHistoricalData(),
        prediction: this.generatePredictionData()
      },
      {
        id: 'PROD-002',
        name: 'Bolígrafo Azul Premium',
        category: 'Escritura',
        currentStock: 5200,
        weeklyDemand: 850,
        price: 2.49,
        historicalData: this.generateHistoricalData(),
        prediction: this.generatePredictionData()
      },
      {
        id: 'PROD-003',
        name: 'Resma Papel A4 80gr',
        category: 'Papel',
        currentStock: 300,
        weeklyDemand: 45,
        price: 22.99,
        historicalData: this.generateHistoricalData(),
        prediction: this.generatePredictionData()
      },
      {
        id: 'PROD-004',
        name: 'Lápiz Grafito #2',
        category: 'Escritura',
        currentStock: 8500,
        weeklyDemand: 1200,
        price: 0.99,
        historicalData: this.generateHistoricalData(),
        prediction: this.generatePredictionData()
      },
      {
        id: 'PROD-005',
        name: 'Folder Manila Tamaño Carta',
        category: 'Organización',
        currentStock: 800,
        weeklyDemand: 120,
        price: 1.99,
        historicalData: this.generateHistoricalData(),
        prediction: this.generatePredictionData()
      }
    ];
    this.productsSubject.next(mockProducts);
  }

  private generateHistoricalData(): number[] {
    return Array.from({ length: 12 }, (_, i) => 
      Math.floor(Math.random() * 400) + 200 + i * 20
    );
  }

  private generatePredictionData(): number[] {
    return Array.from({ length: 16 }, (_, i) => 
      Math.floor(Math.random() * 500) + 300 + i * 25
    );
  }

  // Parsear CSV - Versión CORREGIDA
  parseCSV(csvContent: string): CSVProduct[] {
    const lines = csvContent.split('\n');
    const products: CSVProduct[] = [];
    
    // Saltar la primera línea (encabezados)
    for (let i = 1; i < lines.length; i++) {
      const line = lines[i].trim();
      if (!line) continue;
      
      // Separar por punto y coma
      const parts = line.split(';');
      
      if (parts.length >= 4) {
        // Limpiar el BOM (Byte Order Mark) del primer campo si existe
        let upc = parts[0].trim();
        upc = upc.replace(/^\uFEFF/, ''); // Remover BOM
        upc = upc.replace(/^ï»¿/, ''); // Remover caracteres especiales
        upc = upc.replace(/"/g, ''); // Remover comillas
        
        const descripcion = parts[3]?.trim() || '';
        
        // Crear el objeto base sin las propiedades opcionales
        const product: CSVProduct = {
          upc: upc,
          codigoWM2: parts[1]?.trim() || '',
          itemFlags: parts[2]?.trim() || '',
          descripcion: descripcion
        };
        
        // Solo agregar si tiene UPC
        if (product.upc && product.upc !== 'UPC') {
          // Ahora asignar las propiedades opcionales por separado
          const category = this.detectCategory(descripcion);
          const cleanName = this.cleanProductName(descripcion);
          
          // Usar Type Assertion o crear un nuevo objeto con spread
          const enhancedProduct: CSVProduct = {
            ...product,
            category: category,
            cleanName: cleanName
          };
          
          products.push(enhancedProduct);
        }
      }
    }
    
    return products;
  }

  loadCSVData(products: CSVProduct[]): void {
    this.csvProductsSubject.next(products);
    
    // Convertir productos CSV a productos del sistema para análisis
    const systemProducts = products.slice(0, 50).map((csvProduct, index) => {
      // Usar category del CSV o detectarla
      const category = csvProduct.category || this.detectCategory(csvProduct.descripcion);
      
      return {
        id: `CSV-${String(index + 1).padStart(3, '0')}`,
        name: csvProduct.cleanName || this.cleanProductName(csvProduct.descripcion),
        category: category,
        currentStock: Math.floor(Math.random() * 10000) + 100,
        weeklyDemand: Math.floor(Math.random() * 500) + 50,
        price: parseFloat((Math.random() * 50 + 1).toFixed(2)),
        historicalData: this.generateHistoricalData(),
        prediction: this.generatePredictionData(),
        originalData: csvProduct
      } as Product & { originalData?: CSVProduct };
    });
    
    // Combinar productos mock con CSV
    const allProducts = [...this.productsSubject.value, ...systemProducts];
    this.productsSubject.next(allProducts);
  }

  detectCategory(descripcion: string): string {
    const desc = descripcion.toLowerCase();
    
    if (desc.includes('plastilina') || desc.includes('crayon') || desc.includes('acuarela') || desc.includes('pint')) {
      return 'Arte';
    } else if (desc.includes('bol') || desc.includes('lapiz') || desc.includes('marcador') || desc.includes('plum')) {
      return 'Escritura';
    } else if (desc.includes('papel') || desc.includes('cartul') || desc.includes('foamy') || desc.includes('block')) {
      return 'Papel y Cartón';
    } else if (desc.includes('goma') || desc.includes('peg') || desc.includes('adhesivo') || desc.includes('silicon')) {
      return 'Adhesivos';
    } else if (desc.includes('regla') || desc.includes('compas') || desc.includes('geometria') || desc.includes('transportador')) {
      return 'Geometría';
    } else if (desc.includes('folder') || desc.includes('carpeta') || desc.includes('sobre') || desc.includes('archiv')) {
      return 'Organización';
    } else if (desc.includes('pizarron') || desc.includes('borrador') || desc.includes('gis')) {
      return 'Pizarra';
    } else if (desc.includes('calculadora') || desc.includes('abaco') || desc.includes('escalimetro')) {
      return 'Matemáticas';
    } else if (desc.includes('pincel') || desc.includes('godete') || desc.includes('acuarel')) {
      return 'Pintura';
    } else if (desc.includes('cutter') || desc.includes('tijera') || desc.includes('engrapadora')) {
      return 'Herramientas';
    } else if (desc.includes('cuaderno') || desc.includes('libreta')) {
      return 'Cuadernos';
    } else {
      return 'Otros';
    }
  }

  cleanProductName(descripcion: string): string {
    // Remover prefijos comunes
    let name = descripcion
      .replace(/^PG\s*/i, '')
      .replace(/^P\+G\s*/i, '')
      .replace(/^P&G\s*/i, '')
      .replace(/^P\+G\s*/i, '')
      .trim();
    
    // Capitalizar primera letra de cada palabra
    name = name.toLowerCase()
      .split(' ')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ');
    
    // Limpiar caracteres especiales
    name = name.replace(/Ã¡/g, 'á')
               .replace(/Ã©/g, 'é')
               .replace(/Ã­/g, 'í')
               .replace(/Ã³/g, 'ó')
               .replace(/Ãº/g, 'ú')
               .replace(/Ã±/g, 'ñ')
               .replace(/Ã/g, 'Á')
               .replace(/Ã/g, 'É')
               .replace(/Ã/g, 'Í')
               .replace(/Ã/g, 'Ó')
               .replace(/Ã/g, 'Ú')
               .replace(/Ã/g, 'Ñ');
    
    return name;
  }

  getCSVProducts(): CSVProduct[] {
    return this.csvProductsSubject.value;
  }

  getAllProducts(): Product[] {
    return this.productsSubject.value;
  }

  searchProduct(query: string): Product | null {
    const products = this.productsSubject.value;
    return products.find(p => 
      p.id.toLowerCase().includes(query.toLowerCase()) || 
      p.name.toLowerCase().includes(query.toLowerCase())
    ) || null;
  }

  getProductByUPC(upc: string): CSVProduct | undefined {
    return this.csvProductsSubject.value.find(p => p.upc === upc);
  }

  getProductsByCategory(category: string): Product[] {
    return this.productsSubject.value.filter(p => p.category === category);
  }

  getProductStats(): { total: number, categories: Map<string, number> } {
    const products = this.productsSubject.value;
    const categories = new Map<string, number>();
    
    products.forEach(product => {
      const count = categories.get(product.category) || 0;
      categories.set(product.category, count + 1);
    });
    
    return {
      total: products.length,
      categories: categories
    };
  }

  // Nuevo método para obtener estadísticas de CSV
  getCSVStats(): { total: number, categoryCounts: Map<string, number> } {
    const csvProducts = this.csvProductsSubject.value;
    const categoryCounts = new Map<string, number>();
    
    csvProducts.forEach(product => {
      const category = product.category || 'Sin categoría';
      const count = categoryCounts.get(category) || 0;
      categoryCounts.set(category, count + 1);
    });
    
    return {
      total: csvProducts.length,
      categoryCounts: categoryCounts
    };
  }

  // Método para generar datos de predicción para CSV
  generateCSVPredictions(): HighlightedPrediction[] {
    const csvProducts = this.csvProductsSubject.value;
    const predictions: HighlightedPrediction[] = [];
    
    csvProducts.slice(0, 10).forEach((product, index) => {
      const changePercent = Math.floor(Math.random() * 60) + 5;
      const confidence = 70 + Math.random() * 25;
      
      predictions.push({
        productId: `CSV-${String(index + 1).padStart(3, '0')}`,
        productName: product.cleanName || product.descripcion.substring(0, 40),
        currentDemand: Math.floor(Math.random() * 300) + 50,
        predictedDemand: Math.floor(Math.random() * 450) + 100,
        changePercent: parseFloat(changePercent.toFixed(1)),
        confidence: parseFloat(confidence.toFixed(1)),
        riskLevel: confidence > 85 ? 'low' : confidence > 75 ? 'medium' : 'high',
        recommendation: this.generateRecommendation(changePercent, confidence)
      });
    });
    
    return predictions;
  }

  private generateRecommendation(change: number, confidence: number): string {
    if (change > 40 && confidence > 80) {
      return 'Aumentar stock significativamente';
    } else if (change > 25 && confidence > 70) {
      return 'Incrementar pedidos regulares';
    } else if (change < 10 && confidence > 85) {
      return 'Reducir inventario gradualmente';
    } else {
      return 'Mantener niveles actuales';
    }
  }

  // Método para simular análisis de tendencias
  analyzeTrends(): any {
    const csvProducts = this.csvProductsSubject.value;
    const categoryAnalysis = new Map<string, { count: number, avgLength: number }>();
    
    csvProducts.forEach(product => {
      const category = product.category || 'Sin categoría';
      const current = categoryAnalysis.get(category) || { count: 0, avgLength: 0 };
      
      categoryAnalysis.set(category, {
        count: current.count + 1,
        avgLength: current.avgLength + product.descripcion.length
      });
    });
    
    // Convertir a array para el análisis
    const analysis = Array.from(categoryAnalysis.entries()).map(([category, data]) => ({
      category,
      count: data.count,
      percentage: (data.count / csvProducts.length * 100).toFixed(1),
      avgNameLength: Math.round(data.avgLength / data.count)
    })).sort((a, b) => b.count - a.count);
    
    return {
      totalProducts: csvProducts.length,
      categoryAnalysis: analysis,
      topCategories: analysis.slice(0, 5),
      recommendations: this.generateTrendRecommendations(analysis)
    };
  }

  private generateTrendRecommendations(analysis: any[]): string[] {
    const recommendations: string[] = [];
    
    if (analysis.length > 0) {
      const topCategory = analysis[0];
      recommendations.push(
        `Enfocar análisis en productos de "${topCategory.category}" (${topCategory.percentage}% del total)`
      );
      
      if (topCategory.percentage > 30) {
        recommendations.push('Considerar diversificar el inventario para reducir dependencia de una sola categoría');
      }
      
      const lowCategories = analysis.filter(cat => parseFloat(cat.percentage) < 5);
      if (lowCategories.length > 0) {
        recommendations.push(`Evaluar rentabilidad de categorías con baja representación: ${lowCategories.map(c => c.category).join(', ')}`);
      }
    }
    
    return recommendations;
  }
}