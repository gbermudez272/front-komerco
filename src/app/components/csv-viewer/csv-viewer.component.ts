import { Component, Input, OnInit } from '@angular/core';
import { CSVProduct, DataService } from '../../services/data.service';


@Component({
  selector: 'app-csv-viewer',
  templateUrl: './csv-viewer.component.html',
  styleUrls: ['./csv-viewer.component.scss']
})
export class CsvViewerComponent implements OnInit {
  @Input() csvProducts: CSVProduct[] = [];
  
  displayedColumns: string[] = ['upc', 'codigoWM2', 'descripcion', 'category', 'actions'];
  filteredProducts: CSVProduct[] = [];
  searchTerm: string = '';
  categories: string[] = [];
  selectedCategory: string = 'all';
  pageSize = 10;
  currentPage = 1;
  totalPages = 1;
  currentDate: Date = new Date();
  
  constructor(private dataService: DataService) {}
  
  ngOnInit(): void {
    this.filteredProducts = [...this.csvProducts];
    this.updateCategories();
    this.calculatePages();
  }
  
  updateCategories(): void {
    const uniqueCategories = new Set<string>();
    this.csvProducts.forEach(product => {
      if (product.category) {
        uniqueCategories.add(product.category);
      }
    });
    this.categories = Array.from(uniqueCategories).sort();
  }
  
  applyFilter(): void {
    let filtered = this.csvProducts;
    
    if (this.searchTerm) {
      const term = this.searchTerm.toLowerCase();
      filtered = filtered.filter(product => 
        product.descripcion.toLowerCase().includes(term) ||
        product.upc.toLowerCase().includes(term) ||
        product.codigoWM2.toLowerCase().includes(term)
      );
    }
    
    if (this.selectedCategory !== 'all') {
      filtered = filtered.filter(product => product.category === this.selectedCategory);
    }
    
    this.filteredProducts = filtered;
    this.currentPage = 1;
    this.calculatePages();
  }
  
  calculatePages(): void {
    this.totalPages = Math.ceil(this.filteredProducts.length / this.pageSize);
  }
  
  get paginatedProducts(): CSVProduct[] {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = startIndex + this.pageSize;
    return this.filteredProducts.slice(startIndex, endIndex);
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
  
  analyzeProduct(product: CSVProduct): void {
    console.log('Analizando producto:', product);
    alert(`Iniciando análisis de: ${product.descripcion}`);
  }
  
  clearFilters(): void {
    this.searchTerm = '';
    this.selectedCategory = 'all';
    this.applyFilter();
  }
  
  getCategoryColor(category?: string): string {
    const categoryName = category || 'Sin categoría';
    const colors: { [key: string]: string } = {
      'Arte': '#3182ce',
      'Escritura': '#38a169',
      'Papel y Cartón': '#d69e2e',
      'Adhesivos': '#e53e3e',
      'Geometría': '#805ad5',
      'Organización': '#ed8936',
      'Pizarra': '#38b2ac',
      'Matemáticas': '#ed64a6',
      'Pintura': '#319795',
      'Sin categoría': '#718096',
      'Otros': '#718096'
    };
    return colors[categoryName] || '#718096';
  }

  copyToClipboard(text: string): void {
    navigator.clipboard.writeText(text).then(() => {
      console.log('Texto copiado:', text);
    }).catch(err => {
      console.error('Error al copiar:', err);
    });
  }
}