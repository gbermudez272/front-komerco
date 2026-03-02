export interface CSVProduct {
  upc: string;
  codigoWM2: string;
  itemFlags: string;
  descripcion: string;
  category?: string;
  cleanName?: string;
}

export interface CSVUploadResponse {
  success: boolean;
  message: string;
  totalProducts: number;
  products: CSVProduct[];
  errors?: string[];
}