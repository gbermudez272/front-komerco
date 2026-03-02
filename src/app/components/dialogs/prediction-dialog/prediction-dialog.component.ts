import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-prediction-dialog',
  templateUrl: './prediction-dialog.component.html',
  styleUrls: ['./prediction-dialog.component.scss']
})
export class PredictionDialogComponent {
  predictionData: any;

  constructor(
    public dialogRef: MatDialogRef<PredictionDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any
  ) {
    this.predictionData = data;
  }

  onClose(): void {
    this.dialogRef.close();
  }

  onSave(): void {
    this.dialogRef.close({
      saved: true,
      timestamp: new Date(),
      productId: this.data.product?.id
    });
  }
  getRecommendationText(predicted: number, confidence: number): string {
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
}