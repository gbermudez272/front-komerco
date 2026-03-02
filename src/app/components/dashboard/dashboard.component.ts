import { Component, OnInit, ViewChild, AfterViewInit, ChangeDetectorRef } from '@angular/core';
import { DataService, CSVProduct, HighlightedPrediction } from '../../services/data.service';
import { Product } from '../../models/product.model';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { MatPaginator } from '@angular/material/paginator';
import { MatDialog } from '@angular/material/dialog';
import { PredictionDialogComponent } from '../dialogs/prediction-dialog/prediction-dialog.component';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnInit, AfterViewInit {
  @ViewChild(MatSort) sort!: MatSort;
  @ViewChild(MatPaginator) paginator!: MatPaginator;
  
  // Estado de la aplicación
  isRightPanelCollapsed: boolean = false;
  isPredictionsCollapsed: boolean = false;
  isProductsCollapsed: boolean = false;
  
  // Gestión de vistas
  viewMode: 'table' | 'csv' | 'prediction' | 'welcome' = 'welcome';
  
  // Productos
  selectedProduct: Product | null = null;
  csvProducts: CSVProduct[] = [];
  isLoading: boolean = false;
  allProducts: Product[] = [];
  
  // Tabla
  displayedColumns: string[] = ['id', 'name', 'category', 'currentStock', 'weeklyDemand', 'price', 'trend', 'actions'];
  dataSource = new MatTableDataSource<Product>();
  
  // Estadísticas
  totalProducts: number = 0;
  csvStats = {
    total: 0,
    categories: [] as string[],
    categoryCounts: new Map<string, number>()
  };
  
  // Predicciones destacadas
  highlightedPredictions: HighlightedPrediction[] = [
    {
      productId: 'PROD-001',
      productName: 'Cuaderno Profesional A4',
      currentDemand: 320,
      predictedDemand: 425,
      changePercent: 32.8,
      confidence: 94.2,
      riskLevel: 'low',
      recommendation: 'Aumentar stock en 20%'
    },
    {
      productId: 'PROD-003',
      productName: 'Resma Papel A4 80gr',
      currentDemand: 45,
      predictedDemand: 68,
      changePercent: 51.1,
      confidence: 87.5,
      riskLevel: 'medium',
      recommendation: 'Revisar inventario semanal'
    },
    {
      productId: 'PROD-002',
      productName: 'Bolígrafo Azul Premium',
      currentDemand: 850,
      predictedDemand: 920,
      changePercent: 8.2,
      confidence: 96.8,
      riskLevel: 'low',
      recommendation: 'Mantener niveles actuales'
    },
    {
      productId: 'CSV-001',
      productName: 'Plastilina Rosa',
      currentDemand: 150,
      predictedDemand: 210,
      changePercent: 40.0,
      confidence: 82.3,
      riskLevel: 'high',
      recommendation: 'Pedido urgente necesario'
    },
    {
      productId: 'CSV-005',
      productName: 'Abaco Escolar',
      currentDemand: 45,
      predictedDemand: 75,
      changePercent: 66.7,
      confidence: 79.5,
      riskLevel: 'medium',
      recommendation: 'Programar reabastecimiento'
    },
    {
      productId: 'CSV-012',
      productName: 'Estuche Acuarela',
      currentDemand: 85,
      predictedDemand: 120,
      changePercent: 41.2,
      confidence: 88.9,
      riskLevel: 'medium',
      recommendation: 'Incrementar pedido mensual'
    }
  ];

  // Filtros
  searchTerm: string = '';
  selectedCategory: string = 'all';
  categories: string[] = [];
  
  // Paginación
  pageSize = 10;
  currentPage = 1;
  totalPages = 1;

  constructor(
    private dataService: DataService,
    private dialog: MatDialog,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.loadData();
    this.setupSubscriptions();
    this.initializeDefaultProduct();
  }

  ngAfterViewInit() {
    this.dataSource.sort = this.sort;
    this.dataSource.paginator = this.paginator;
    this.cdr.detectChanges();
  }

  private loadData(): void {
    this.allProducts = this.dataService.getAllProducts();
    this.dataSource.data = this.allProducts;
    this.totalProducts = this.allProducts.length;
    this.updateCategories();
    this.applyTableFilters();
  }

  private setupSubscriptions(): void {
    this.dataService.csvProducts$.subscribe(products => {
      this.csvProducts = products;
      if (products.length > 0) {
        this.updateCSVStats();
        if (this.viewMode === 'welcome') {
          this.viewMode = 'csv';
        }
      }
    });

    this.dataService.products$.subscribe(products => {
      this.allProducts = products;
      this.dataSource.data = products;
      this.totalProducts = products.length;
      this.updateCategories();
      this.applyTableFilters();
    });
  }

  private initializeDefaultProduct(): void {
    if (this.allProducts.length > 0) {
      this.selectedProduct = this.allProducts[0];
    }
  }

  // Manejo de vistas
  onFileUploaded(): void {
    this.viewMode = 'csv';
    this.selectedProduct = null;
  }

  onPredict(): void {
    if (this.selectedProduct) {
      this.isLoading = true;
      this.viewMode = 'prediction';
      
      setTimeout(() => {
        this.isLoading = false;
      }, 1000);
    }
  }

  switchToTableView(): void {
    this.viewMode = 'table';
    this.selectedProduct = null;
    this.clearTableFilters();
  }

  switchToCSVView(): void {
    if (this.csvProducts.length > 0) {
      this.viewMode = 'csv';
      this.selectedProduct = null;
    }
  }

  switchToWelcomeView(): void {
    this.viewMode = 'welcome';
    this.selectedProduct = null;
  }

  // Métodos de tabla
  applyTableFilters(): void {
    let filtered = this.allProducts;
    
    if (this.searchTerm) {
      const term = this.searchTerm.toLowerCase();
      filtered = filtered.filter(product => 
        product.name.toLowerCase().includes(term) ||
        product.id.toLowerCase().includes(term) ||
        product.category.toLowerCase().includes(term)
      );
    }
    
    if (this.selectedCategory !== 'all') {
      filtered = filtered.filter(product => product.category === this.selectedCategory);
    }
    
    this.dataSource.data = filtered;
    this.totalProducts = filtered.length;
    this.updatePagination();
  }

  clearTableFilters(): void {
    this.searchTerm = '';
    this.selectedCategory = 'all';
    this.applyTableFilters();
  }

  updateCategories(): void {
    const uniqueCategories = new Set<string>();
    this.allProducts.forEach(product => {
      uniqueCategories.add(product.category);
    });
    this.categories = Array.from(uniqueCategories).sort();
  }

  selectProduct(product: Product): void {
    this.selectedProduct = product;
    this.viewMode = 'prediction';
  }

  selectFromHighlighted(prediction: HighlightedPrediction): void {
    const product = this.allProducts.find(p => p.id === prediction.productId);
    if (product) {
      this.selectedProduct = product;
      this.viewMode = 'prediction';
    }
  }

  // Métodos de CSV
  updateCSVStats(): void {
    const categories = new Set<string>();
    const categoryCounts = new Map<string, number>();
    
    this.csvProducts.forEach(product => {
      const category = product.category || 'Sin categoría';
      categories.add(category);
      const count = categoryCounts.get(category) || 0;
      categoryCounts.set(category, count + 1);
    });
    
    this.csvStats = {
      total: this.csvProducts.length,
      categories: Array.from(categories).sort(),
      categoryCounts: categoryCounts
    };
  }

  // Análisis y predicciones
  onAnalyze(): void {
    if (this.selectedProduct) {
      this.isLoading = true;
      
      setTimeout(() => {
        this.isLoading = false;
        this.openPredictionDialog();
      }, 1500);
    }
  }

  openPredictionDialog(): void {
    const dialogRef = this.dialog.open(PredictionDialogComponent, {
      width: '800px',
      data: {
        product: this.selectedProduct,
        predictions: this.generateDetailedPredictions()
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        console.log('Análisis guardado:', result);
      }
    });
  }

  generatePredictions(): void {
    this.isLoading = true;
    
    setTimeout(() => {
      this.isLoading = false;
      this.highlightedPredictions = this.generateNewPredictions();
      alert(`Análisis predictivo completado para ${this.csvProducts.length} productos`);
    }, 2000);
  }

  analyzeTrends(): void {
    this.isLoading = true;
    
    setTimeout(() => {
      this.isLoading = false;
      this.showTrendAnalysis();
    }, 1500);
  }

  exportAnalysis(): void {
    const data = {
      products: this.csvProducts,
      predictions: this.highlightedPredictions,
      generatedAt: new Date().toISOString()
    };
    
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `analisis-productos-${new Date().getTime()}.json`;
    a.click();
    window.URL.revokeObjectURL(url);
    
    alert('Análisis exportado exitosamente');
  }

  // Métodos auxiliares
  private generateDetailedPredictions(): any {
    return {
      weeklyForecast: Array.from({ length: 12 }, (_, i) => ({
        week: i + 1,
        predicted: Math.floor(Math.random() * 500) + 300,
        confidence: 85 + Math.random() * 10
      })),
      recommendations: [
        'Aumentar stock en un 15% para las próximas 4 semanas',
        'Programar reabastecimiento cada 2 semanas',
        'Considerar promoción para incrementar rotación'
      ],
      riskFactors: [
        'Demanda estacional alta en próximos meses',
        'Posible escasez de materia prima',
        'Competencia incrementando precios'
      ]
    };
  }

  private generateNewPredictions(): HighlightedPrediction[] {
    const newPredictions = [...this.highlightedPredictions];
    
    // Agregar predicciones para productos CSV
    this.csvProducts.slice(0, 3).forEach((product, index) => {
      const changePercent = Math.floor(Math.random() * 50) + 10;
      const confidence = 75 + Math.random() * 20;
      
      newPredictions.push({
        productId: `CSV-${String(index + 100).padStart(3, '0')}`,
        productName: product.cleanName || product.descripcion.substring(0, 30) + '...',
        currentDemand: Math.floor(Math.random() * 200) + 50,
        predictedDemand: Math.floor(Math.random() * 300) + 100,
        changePercent: parseFloat(changePercent.toFixed(1)),
        confidence: parseFloat(confidence.toFixed(1)),
        riskLevel: confidence > 85 ? 'low' : confidence > 75 ? 'medium' : 'high',
        recommendation: this.getPredictionRecommendation(changePercent, confidence)
      });
    });
    
    return newPredictions;
  }

  // Función renombrada para evitar duplicación
  private getPredictionRecommendation(change: number, confidence: number): string {
    if (change > 40 && confidence > 80) {
      return 'Aumentar stock significativamente';
    } else if (change > 25 && confidence > 70) {
      return 'Incrementar pedidos regulares';
    } else if (change < 10 && confidence > 85) {
      return 'Reducir inventario';
    } else {
      return 'Mantener niveles actuales';
    }
  }

  private showTrendAnalysis(): void {
    const dialogRef = this.dialog.open(PredictionDialogComponent, {
      width: '900px',
      data: {
        title: 'Análisis de Tendencias',
        type: 'trends',
        trends: this.generateTrendAnalysis()
      }
    });
  }

  private generateTrendAnalysis(): any {
    const categories = new Map<string, number>();
    this.csvProducts.forEach(product => {
      const category = product.category || 'Sin categoría';
      const count = categories.get(category) || 0;
      categories.set(category, count + 1);
    });
    
    const categoryDistribution = Array.from(categories.entries()).map(([name, count]) => ({
      name,
      count,
      percentage: (count / this.csvProducts.length * 100).toFixed(1)
    }));
    
    return {
      totalProducts: this.csvProducts.length,
      categoryDistribution: categoryDistribution,
      topProducts: this.csvProducts.slice(0, 10).map(p => ({
        name: p.cleanName || p.descripcion,
        upc: p.upc,
        category: p.category || 'Sin categoría'
      })),
      recommendations: [
        'Enfocar análisis en productos de categoría "Arte" que representan el 35% del inventario',
        'Considerar reducción de productos de categoría "Otros" con baja rotación',
        'Implementar análisis de precio óptimo para productos de alta demanda'
      ]
    };
  }

  // Métodos de UI
  getRiskColor(riskLevel: string): string {
    switch (riskLevel) {
      case 'low': return '#38a169';
      case 'medium': return '#d69e2e';
      case 'high': return '#e53e3e';
      default: return '#718096';
    }
  }

  getChangeColor(percent: number): string {
    if (percent >= 40) return '#e53e3e';
    if (percent >= 25) return '#d69e2e';
    if (percent >= 10) return '#38a169';
    return '#718096';
  }

  getTrendIcon(trend: number): string {
    if (trend > 10) return 'trending_up';
    if (trend < -10) return 'trending_down';
    return 'trending_flat';
  }

  getTrendColor(trend: number): string {
    if (trend > 10) return '#e53e3e';
    if (trend < -10) return '#38a169';
    return '#718096';
  }

  toggleRightPanel(): void {
    this.isRightPanelCollapsed = !this.isRightPanelCollapsed;
  }

  togglePredictionsSection(): void {
    this.isPredictionsCollapsed = !this.isPredictionsCollapsed;
  }

  toggleProductsSection(): void {
    this.isProductsCollapsed = !this.isProductsCollapsed;
  }

  // Paginación
  get paginatedProducts(): Product[] {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = startIndex + this.pageSize;
    return this.dataSource.data.slice(startIndex, endIndex);
  }

  get totalFilteredProducts(): number {
    return this.dataSource.data.length;
  }

  prevPage(): void {
    if (this.currentPage > 1) {
      this.currentPage--;
    }
  }

  nextPage(): void {
    if (this.currentPage < this.totalPages) {
      this.currentPage++;
    }
  }

  goToPage(page: number): void {
    if (page >= 1 && page <= this.totalPages) {
      this.currentPage = page;
    }
  }

  getPageNumbers(): number[] {
    const pages: number[] = [];
    const maxPagesToShow = 5;
    
    let startPage = Math.max(1, this.currentPage - Math.floor(maxPagesToShow / 2));
    let endPage = startPage + maxPagesToShow - 1;
    
    if (endPage > this.totalPages) {
      endPage = this.totalPages;
      startPage = Math.max(1, endPage - maxPagesToShow + 1);
    }
    
    for (let i = startPage; i <= endPage; i++) {
      pages.push(i);
    }
    
    return pages;
  }

  updatePagination(): void {
    this.totalPages = Math.ceil(this.totalFilteredProducts / this.pageSize);
    if (this.currentPage > this.totalPages) {
      this.currentPage = 1;
    }
  }

  // Métodos para el panel derecho
  getCategoryDistribution(): Array<{name: string, count: number, percentage: number}> {
    const distribution = [];
    for (const [category, count] of this.csvStats.categoryCounts) {
      const percentage = (count / this.csvStats.total) * 100;
      distribution.push({
        name: category,
        count,
        percentage: parseFloat(percentage.toFixed(1))
      });
    }
    return distribution.sort((a, b) => b.count - a.count);
  }

  getInventoryValue(): number {
    return this.allProducts.reduce((total, product) => {
      return total + (product.currentStock * product.price);
    }, 0);
  }

  getAverageDemand(): number {
    if (this.allProducts.length === 0) return 0;
    const totalDemand = this.allProducts.reduce((sum, product) => sum + product.weeklyDemand, 0);
    return Math.round(totalDemand / this.allProducts.length);
  }

  getLowStockProducts(): Product[] {
    return this.allProducts.filter(product => {
      const weeksOfSupply = product.currentStock / product.weeklyDemand;
      return weeksOfSupply < 2;
    }).slice(0, 5);
  }

  // Métodos para CSV Viewer
  copyToClipboard(text: string): void {
    navigator.clipboard.writeText(text).then(() => {
      console.log('Texto copiado:', text);
    }).catch(err => {
      console.error('Error al copiar:', err);
    });
  }

  // Método para obtener la fecha actual formateada
  get currentDate(): Date {
    return new Date();
  }

  // Método para resetear la aplicación
  resetApplication(): void {
    this.viewMode = 'welcome';
    this.selectedProduct = null;
    this.csvProducts = [];
    this.searchTerm = '';
    this.selectedCategory = 'all';
    this.currentPage = 1;
    this.isLoading = false;
    this.loadData();
  }

  // Método auxiliar para el PredictionDialog - AHORA ÚNICO
  getRecommendationForDialog(predicted: number, confidence: number): string {
    if (predicted > 400 && confidence > 90) {
      return 'Aumentar producción significativamente';
    } else if (predicted > 250 && confidence > 80) {
      return 'Incrementar inventario de seguridad';
    } else if (predicted < 100 && confidence > 85) {
      return 'Considerar reducción de stock';
    } else {
      return 'Mantener niveles actuales';
    }
  }

  // Método para manejar drop de archivos (si es necesario)
  handleDrop(event: DragEvent): void {
    event.preventDefault();
    const files = event.dataTransfer?.files;
    if (files && files.length > 0) {
      // Simular el cambio de archivo
      console.log('Archivo arrastrado:', files[0].name);
      // Aquí podrías llamar al método de carga del sidebar
    }
  }
}