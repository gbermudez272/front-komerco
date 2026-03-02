import { Component, EventEmitter, Output } from '@angular/core';
import { DataService } from '../../services/data.service';

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.scss']
})
export class SidebarComponent {
  @Output() predict = new EventEmitter<void>();
  @Output() fileUploaded = new EventEmitter<boolean>();
  
  searchQuery: string = '';
  isCollapsed: boolean = false;
  isUploading: boolean = false;
  uploadProgress: number = 0;
  fileName: string = '';
  uploadError: string = '';
  
  constructor(private dataService: DataService) {}

  onFileUpload(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      this.fileName = input.files[0].name;
      this.isUploading = true;
      this.uploadProgress = 0;
      this.uploadError = '';
      
      const file = input.files[0];
      const reader = new FileReader();
      
      reader.onload = (e) => {
        try {
          const csvContent = e.target?.result as string;
          
          // Simular progreso de carga
          const progressInterval = setInterval(() => {
            this.uploadProgress += 10;
            if (this.uploadProgress >= 100) {
              clearInterval(progressInterval);
              
              // Parsear CSV
              const products = this.dataService.parseCSV(csvContent);
              
              if (products.length > 0) {
                // Cargar datos en el servicio
                this.dataService.loadCSVData(products);
                
                // Notificar al dashboard
                this.fileUploaded.emit(true);
                
                alert(`Archivo cargado exitosamente!\n${products.length} productos procesados.`);
              } else {
                this.uploadError = 'No se pudieron procesar productos del archivo CSV.';
              }
              
              this.isUploading = false;
            }
          }, 100);
          
        } catch (error) {
          console.error('Error processing CSV:', error);
          this.uploadError = 'Error al procesar el archivo CSV.';
          this.isUploading = false;
        }
      };
      
      reader.onerror = () => {
        this.uploadError = 'Error al leer el archivo.';
        this.isUploading = false;
      };
      
      reader.readAsText(file);
    }
  }

  onSearch(): void {
    if (this.searchQuery.trim()) {
      const product = this.dataService.searchProduct(this.searchQuery);
      if (product) {
        alert(`Producto encontrado: ${product.name} (${product.id})`);
      } else {
        alert('Producto no encontrado');
      }
    }
  }

  onPredict(): void {
    if (this.searchQuery.trim()) {
      this.predict.emit();
    } else {
      alert('Por favor, ingrese un código de producto primero.');
    }
  }

  toggleCollapse(): void {
    this.isCollapsed = !this.isCollapsed;
  }

  cancelUpload(): void {
    this.isUploading = false;
    this.uploadProgress = 0;
    this.fileName = '';
  }
  handleDrop(event: DragEvent): void {
  event.preventDefault();
  const input = event.target as HTMLInputElement;
  if (event.dataTransfer?.files && event.dataTransfer.files.length > 0) {
    // Simular el cambio de archivo
    const fileInput = document.getElementById('fileInput') as HTMLInputElement;
    if (fileInput) {
      fileInput.files = event.dataTransfer.files;
      const changeEvent = new Event('change');
      fileInput.dispatchEvent(changeEvent);
    }
  }
}
}