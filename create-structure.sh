#!/bin/bash

echo "=== Creando estructura completa del proyecto ==="

# Crear directorios principales
echo "Creando directorios..."
mkdir -p src/app/components/login
mkdir -p src/app/components/dashboard
mkdir -p src/app/components/header
mkdir -p src/app/components/sidebar
mkdir -p src/app/components/product-card
mkdir -p src/app/components/charts
mkdir -p src/app/services
mkdir -p src/app/models
mkdir -p src/app/guards
mkdir -p src/assets/images
mkdir -p src/assets/styles
mkdir -p src/environments

echo "✓ Directorios creados"

# 1. App Module
echo "Creando app.module.ts..."
cat > src/app/app.module.ts << 'EOF'
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';

// Angular Material
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { MatCardModule } from '@angular/material/card';
import { MatTabsModule } from '@angular/material/tabs';
import { MatIconModule } from '@angular/material/icon';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatSelectModule } from '@angular/material/select';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatMenuModule } from '@angular/material/menu';
import { MatDividerModule } from '@angular/material/divider';

// ApexCharts
import { NgApexchartsModule } from 'ng-apexcharts';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { LoginComponent } from './components/login/login.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { HeaderComponent } from './components/header/header.component';
import { SidebarComponent } from './components/sidebar/sidebar.component';
import { ProductCardComponent } from './components/product-card/product-card.component';
import { PredictiveChartComponent } from './components/charts/predictive-chart.component';

@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    DashboardComponent,
    HeaderComponent,
    SidebarComponent,
    ProductCardComponent,
    PredictiveChartComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    FormsModule,
    ReactiveFormsModule,
    HttpClientModule,
    
    // Angular Material
    MatToolbarModule,
    MatButtonModule,
    MatInputModule,
    MatCardModule,
    MatTabsModule,
    MatIconModule,
    MatSidenavModule,
    MatListModule,
    MatSelectModule,
    MatProgressSpinnerModule,
    MatMenuModule,
    MatDividerModule,
    
    // ApexCharts
    NgApexchartsModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
EOF

# 2. App Component
echo "Creando app.component.ts..."
cat > src/app/app.component.ts << 'EOF'
import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  title = 'stationery-predictive-analytics';
  
  isSidebarOpen = true;

  toggleSidebar(): void {
    this.isSidebarOpen = !this.isSidebarOpen;
  }
}
EOF

echo "Creando app.component.html..."
cat > src/app/app.component.html << 'EOF'
<app-header (toggleSidebar)="toggleSidebar()"></app-header>

<div class="app-container">
  <router-outlet></router-outlet>
</div>
EOF

echo "Creando app.component.scss..."
cat > src/app/app.component.scss << 'EOF'
.app-container {
  margin-top: 64px;
  height: calc(100vh - 64px);
  overflow: hidden;
}
EOF

# 3. Routing Module
echo "Creando app-routing.module.ts..."
cat > src/app/app-routing.module.ts << 'EOF'
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { AuthGuard } from './guards/auth.guard';

const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { 
    path: 'dashboard', 
    component: DashboardComponent,
    canActivate: [AuthGuard]
  },
  { path: '**', redirectTo: '/login' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
EOF

# 4. Services
echo "Creando servicios..."

# Auth Service
cat > src/app/services/auth.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private isAuthenticated = false;
  private readonly DEMO_USER = 'admin';
  private readonly DEMO_PASSWORD = 'admin123';

  constructor(private router: Router) {
    this.isAuthenticated = localStorage.getItem('isLoggedIn') === 'true';
  }

  login(username: string, password: string): boolean {
    if (username === this.DEMO_USER && password === this.DEMO_PASSWORD) {
      this.isAuthenticated = true;
      localStorage.setItem('isLoggedIn', 'true');
      return true;
    }
    return false;
  }

  logout(): void {
    this.isAuthenticated = false;
    localStorage.removeItem('isLoggedIn');
    this.router.navigate(['/login']);
  }

  isLoggedIn(): boolean {
    return this.isAuthenticated;
  }

  getUsername(): string {
    return this.DEMO_USER;
  }
}
EOF

# Data Service
cat > src/app/services/data.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { Product } from '../models/product.model';

@Injectable({
  providedIn: 'root'
})
export class DataService {
  private productsSubject = new BehaviorSubject<Product[]>([]);
  products$: Observable<Product[]> = this.productsSubject.asObservable();

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
      }
    ];
    this.productsSubject.next(mockProducts);
  }

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

  searchProduct(query: string): Product | null {
    const products = this.productsSubject.value;
    return products.find(p => 
      p.id.toLowerCase().includes(query.toLowerCase()) || 
      p.name.toLowerCase().includes(query.toLowerCase())
    ) || null;
  }

  getMockProduct(): Product {
    return {
      id: 'PROD-001',
      name: 'Cuaderno Profesional A4',
      category: 'Escritura',
      currentStock: 1250,
      weeklyDemand: 320,
      price: 15.99,
      historicalData: this.generateHistoricalData(),
      prediction: this.generatePredictionData(),
      reorderPoint: 400,
      safetyStock: 200,
      leadTime: 7,
      lastOrderDate: '2024-01-15'
    };
  }

  getAllProducts(): Product[] {
    return this.productsSubject.value;
  }
}
EOF

# 5. Models
echo "Creando modelos..."

# Product Model
cat > src/app/models/product.model.ts << 'EOF'
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
EOF

# User Model
cat > src/app/models/user.model.ts << 'EOF'
export interface User {
  username: string;
  role: 'admin' | 'analyst' | 'viewer';
  name: string;
  email: string;
}
EOF

# 6. Guards
echo "Creando guards..."

cat > src/app/guards/auth.guard.ts << 'EOF'
import { Injectable } from '@angular/core';
import { Router, CanActivate } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(): boolean {
    if (this.authService.isLoggedIn()) {
      return true;
    } else {
      this.router.navigate(['/login']);
      return false;
    }
  }
}
EOF

# 7. Components
echo "Creando componentes..."

# Login Component
cat > src/app/components/login/login.component.ts << 'EOF'
import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {
  loginForm: FormGroup;
  errorMessage: string = '';
  isLoading: boolean = false;

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private router: Router
  ) {
    this.loginForm = this.fb.group({
      username: ['admin', Validators.required],
      password: ['admin123', Validators.required]
    });
  }

  onSubmit(): void {
    if (this.loginForm.valid) {
      this.isLoading = true;
      const { username, password } = this.loginForm.value;
      
      // Simulate API call
      setTimeout(() => {
        if (this.authService.login(username, password)) {
          this.router.navigate(['/dashboard']);
        } else {
          this.errorMessage = 'Credenciales incorrectas';
        }
        this.isLoading = false;
      }, 1000);
    }
  }
}
EOF

cat > src/app/components/login/login.component.html << 'EOF'
<div class="login-container">
  <mat-card class="login-card">
    <mat-card-header>
      <div class="logo-container">
        <h1 class="logo-text">Kommerco</h1>
        <span class="logo-subtitle">Predictive Analytics</span>
      </div>
    </mat-card-header>

    <mat-card-content>
      <form [formGroup]="loginForm" (ngSubmit)="onSubmit()">
        <div class="form-field">
          <mat-form-field appearance="outline" class="full-width">
            <mat-label>Usuario</mat-label>
            <input matInput formControlName="username" placeholder="admin">
            <mat-icon matSuffix>person</mat-icon>
            <mat-error *ngIf="loginForm.get('username')?.hasError('required')">
              El usuario es requerido
            </mat-error>
          </mat-form-field>
        </div>

        <div class="form-field">
          <mat-form-field appearance="outline" class="full-width">
            <mat-label>Contraseña</mat-label>
            <input matInput type="password" formControlName="password" placeholder="admin123">
            <mat-icon matSuffix>lock</mat-icon>
            <mat-error *ngIf="loginForm.get('password')?.hasError('required')">
              La contraseña es requerida
            </mat-error>
          </mat-form-field>
        </div>

        <div *ngIf="errorMessage" class="error-message">
          <mat-icon>error</mat-icon>
          {{ errorMessage }}
        </div>

        <button 
          mat-raised-button 
          color="primary" 
          type="submit" 
          class="login-button"
          [disabled]="!loginForm.valid || isLoading">
          <mat-spinner diameter="20" *ngIf="isLoading"></mat-spinner>
          <span *ngIf="!isLoading">Iniciar Sesión</span>
        </button>

        <div class="demo-credentials">
          <p><strong>Credenciales demo:</strong></p>
          <p>Usuario: admin</p>
          <p>Contraseña: admin123</p>
        </div>
      </form>
    </mat-card-content>
  </mat-card>
</div>
EOF

cat > src/app/components/login/login.component.scss << 'EOF'
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-card {
  width: 100%;
  max-width: 400px;
  padding: 30px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  border-radius: 16px;
}

.logo-container {
  text-align: center;
  margin-bottom: 30px;
  width: 100%;
}

.logo-text {
  color: #3f51b5;
  font-size: 2.5rem;
  font-weight: 700;
  margin: 0;
  letter-spacing: -1px;
}

.logo-subtitle {
  color: #666;
  font-size: 1rem;
  font-weight: 400;
  margin-top: 5px;
  display: block;
}

.form-field {
  margin-bottom: 20px;
}

.full-width {
  width: 100%;
}

.login-button {
  width: 100%;
  padding: 12px;
  font-size: 1.1rem;
  margin-top: 10px;
  border-radius: 8px;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;
  
  mat-spinner {
    margin: 0;
  }
}

.error-message {
  color: #f44336;
  text-align: center;
  margin: 15px 0;
  padding: 10px;
  background-color: #ffebee;
  border-radius: 4px;
  border-left: 4px solid #f44336;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  
  mat-icon {
    font-size: 18px;
  }
}

.demo-credentials {
  margin-top: 25px;
  padding: 15px;
  background-color: #f5f7fa;
  border-radius: 8px;
  border-left: 4px solid #4caf50;
  
  p {
    margin: 5px 0;
    color: #555;
    font-size: 0.9rem;
  }
  
  strong {
    color: #333;
  }
}
EOF

# Header Component
cat > src/app/components/header/header.component.ts << 'EOF'
import { Component, Output, EventEmitter } from '@angular/core';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent {
  @Output() toggleSidebar = new EventEmitter<void>();
  
  navTabs = [
    { label: 'Predicciones', icon: 'trending_up' },
    { label: 'Inventario', icon: 'inventory_2' },
    { label: 'Reportes', icon: 'assessment' },
    { label: 'Configuración', icon: 'settings' }
  ];
  
  activeTab = this.navTabs[0];

  constructor(private authService: AuthService) {}

  onToggleSidebar(): void {
    this.toggleSidebar.emit();
  }

  onLogout(): void {
    this.authService.logout();
  }

  getUsername(): string {
    return this.authService.getUsername();
  }

  selectTab(tab: any): void {
    this.activeTab = tab;
    // In a real app, you would navigate or load different content
    console.log('Tab selected:', tab.label);
  }
}
EOF

cat > src/app/components/header/header.component.html << 'EOF'
<mat-toolbar class="header-toolbar" color="primary">
  <!-- Left Section -->
  <div class="header-left">
    <button mat-icon-button (click)="onToggleSidebar()" class="sidebar-toggle">
      <mat-icon>menu</mat-icon>
    </button>
    
    <div class="logo">
      <h1 class="logo-text">Kommerco</h1>
      <span class="logo-beta">Predictive Analytics v1.0</span>
    </div>
  </div>

  <!-- Center Section - Navigation Tabs -->
  <div class="header-center">
    <nav class="nav-tabs">
      <button 
        *ngFor="let tab of navTabs"
        mat-button 
        (click)="selectTab(tab)"
        [class.active]="activeTab.label === tab.label"
        class="nav-tab">
        <mat-icon class="tab-icon">{{tab.icon}}</mat-icon>
        {{tab.label}}
      </button>
    </nav>
  </div>

  <!-- Right Section -->
  <div class="header-right">
    <button mat-icon-button [matMenuTriggerFor]="userMenu" class="user-button">
      <mat-icon>account_circle</mat-icon>
    </button>
    
    <mat-menu #userMenu="matMenu">
      <div class="user-menu-header">
        <mat-icon>account_circle</mat-icon>
        <div class="user-info">
          <strong>{{ getUsername() }}</strong>
          <span>Administrador</span>
        </div>
      </div>
      <mat-divider></mat-divider>
      <button mat-menu-item>
        <mat-icon>person</mat-icon>
        <span>Perfil</span>
      </button>
      <button mat-menu-item>
        <mat-icon>settings</mat-icon>
        <span>Configuración</span>
      </button>
      <mat-divider></mat-divider>
      <button mat-menu-item (click)="onLogout()" class="logout-item">
        <mat-icon>logout</mat-icon>
        <span>Cerrar Sesión</span>
      </button>
    </mat-menu>
  </div>
</mat-toolbar>
EOF

cat > src/app/components/header/header.component.scss << 'EOF'
.header-toolbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  height: 64px;
  padding: 0 20px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 15px;
  min-width: 250px;
}

.sidebar-toggle {
  margin-right: 10px;
}

.logo {
  display: flex;
  flex-direction: column;
}

.logo-text {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 700;
  color: white;
  letter-spacing: -0.5px;
}

.logo-beta {
  font-size: 0.7rem;
  color: rgba(255, 255, 255, 0.8);
  margin-top: -2px;
}

.header-center {
  flex: 1;
  display: flex;
  justify-content: center;
  max-width: 600px;
}

.nav-tabs {
  display: flex;
  gap: 5px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  padding: 4px;
}

.nav-tab {
  min-width: 120px;
  margin: 0 2px;
  border-radius: 6px;
  color: white;
  transition: all 0.3s ease;
  
  .tab-icon {
    margin-right: 8px;
    font-size: 18px;
  }
  
  &:hover {
    background: rgba(255, 255, 255, 0.2);
  }
  
  &.active {
    background: rgba(255, 255, 255, 0.25);
  }
}

.header-right {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 250px;
  justify-content: flex-end;
}

.user-button {
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.1);
  
  &:hover {
    background: rgba(255, 255, 255, 0.2);
  }
}

.user-menu-header {
  display: flex;
  align-items: center;
  padding: 16px;
  gap: 12px;
  
  mat-icon {
    font-size: 40px;
    width: 40px;
    height: 40px;
    color: #666;
  }
  
  .user-info {
    display: flex;
    flex-direction: column;
    
    strong {
      font-size: 1rem;
      color: #333;
    }
    
    span {
      font-size: 0.85rem;
      color: #666;
    }
  }
}

.logout-item {
  color: #f44336;
  
  mat-icon {
    color: #f44336;
  }
}
EOF

# Sidebar Component
cat > src/app/components/sidebar/sidebar.component.ts << 'EOF'
import { Component, EventEmitter, Output } from '@angular/core';
import { DataService } from '../../services/data.service';

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.scss']
})
export class SidebarComponent {
  @Output() predict = new EventEmitter<void>();
  
  searchQuery: string = '';
  isCollapsed: boolean = false;
  
  constructor(private dataService: DataService) {}

  onFileUpload(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      alert(`Archivo cargado: ${input.files[0].name}\n(Funcionalidad simulada)`);
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
}
EOF

cat > src/app/components/sidebar/sidebar.component.html << 'EOF'
<mat-sidenav-container class="sidebar-container">
  <mat-sidenav mode="side" opened class="sidebar" [style.width.px]="isCollapsed ? 70 : 280">
    <div class="sidebar-header">
      <h3 *ngIf="!isCollapsed">Herramientas</h3>
      <button mat-icon-button (click)="toggleCollapse()" class="collapse-button">
        <mat-icon>{{ isCollapsed ? 'chevron_right' : 'chevron_left' }}</mat-icon>
      </button>
    </div>

    <mat-divider></mat-divider>

    <div class="sidebar-content" [class.collapsed]="isCollapsed">
      <!-- File Upload Section -->
      <div class="sidebar-section" *ngIf="!isCollapsed">
        <h4 class="section-title">
          <mat-icon>cloud_upload</mat-icon>
          Carga de Datos
        </h4>
        <div class="file-upload-area" (click)="fileInput.click()">
          <mat-icon>insert_drive_file</mat-icon>
          <p>Arrastra o haz clic para cargar</p>
          <span class="file-types">CSV, Excel (máx. 10MB)</span>
        </div>
        <input #fileInput type="file" accept=".csv,.xlsx,.xls" (change)="onFileUpload($event)" hidden>
      </div>

      <mat-divider *ngIf="!isCollapsed"></mat-divider>

      <!-- Product Search -->
      <div class="sidebar-section">
        <h4 class="section-title" *ngIf="!isCollapsed">
          <mat-icon>search</mat-icon>
          Búsqueda de Producto
        </h4>
        <div class="search-container">
          <mat-form-field appearance="outline" class="search-field" *ngIf="!isCollapsed">
            <mat-label>Código de Producto</mat-label>
            <input matInput [(ngModel)]="searchQuery" placeholder="Ej: PROD-001">
            <mat-icon matSuffix>tag</mat-icon>
          </mat-form-field>
          
          <button mat-icon-button class="search-button-icon" *ngIf="isCollapsed" (click)="onSearch()">
            <mat-icon>search</mat-icon>
          </button>
          
          <button mat-raised-button color="primary" class="search-button" *ngIf="!isCollapsed" (click)="onSearch()">
            <mat-icon>search</mat-icon>
            Buscar
          </button>
        </div>
      </div>

      <!-- Predict Button -->
      <div class="predict-section">
        <button mat-raised-button color="accent" class="predict-button" (click)="onPredict()" [class.collapsed]="isCollapsed">
          <mat-icon>trending_up</mat-icon>
          <span *ngIf="!isCollapsed">Predecir</span>
        </button>
      </div>

      <!-- Quick Actions -->
      <div class="sidebar-section" *ngIf="!isCollapsed">
        <h4 class="section-title">
          <mat-icon>flash_on</mat-icon>
          Acciones Rápidas
        </h4>
        <button mat-stroked-button class="quick-action">
          <mat-icon>history</mat-icon>
          Historial
        </button>
        <button mat-stroked-button class="quick-action">
          <mat-icon>download</mat-icon>
          Exportar
        </button>
        <button mat-stroked-button class="quick-action">
          <mat-icon>notifications</mat-icon>
          Alertas
        </button>
      </div>
    </div>
  </mat-sidenav>
</mat-sidenav-container>
EOF

cat > src/app/components/sidebar/sidebar.component.scss << 'EOF'
.sidebar-container {
  height: calc(100vh - 64px);
  
  &.collapsed {
    .sidebar-content {
      padding: 10px;
    }
  }
}

.sidebar {
  background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
  border-right: 1px solid #e2e8f0;
  box-shadow: 2px 0 10px rgba(0, 0, 0, 0.05);
  transition: width 0.3s ease;
}

.sidebar-header {
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  h3 {
    margin: 0;
    color: #2d3748;
    font-weight: 600;
  }
}

.collapse-button {
  background: #edf2f7;
  
  &:hover {
    background: #e2e8f0;
  }
}

.sidebar-content {
  padding: 20px;
  transition: padding 0.3s ease;
  
  &.collapsed {
    padding: 10px;
    
    .sidebar-section {
      margin-bottom: 20px;
    }
  }
}

.sidebar-section {
  margin-bottom: 30px;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #4a5568;
  font-size: 0.9rem;
  margin-bottom: 15px;
  
  mat-icon {
    font-size: 18px;
    color: #667eea;
  }
}

.file-upload-area {
  border: 2px dashed #cbd5e0;
  border-radius: 8px;
  padding: 25px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  background: #f7fafc;
  
  &:hover {
    border-color: #667eea;
    background: #f0f4f8;
  }
  
  mat-icon {
    font-size: 40px;
    color: #a0aec0;
    margin-bottom: 10px;
  }
  
  p {
    margin: 5px 0;
    color: #4a5568;
    font-weight: 500;
  }
  
  .file-types {
    font-size: 0.8rem;
    color: #718096;
  }
}

.search-container {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.search-field {
  width: 100%;
  
  ::ng-deep .mat-form-field-outline {
    background-color: white;
  }
}

.search-button {
  width: 100%;
  padding: 8px;
  
  mat-icon {
    margin-right: 8px;
  }
}

.search-button-icon {
  width: 48px;
  height: 48px;
  background: #667eea;
  color: white;
  align-self: center;
  
  &:hover {
    background: #5a67d8;
  }
}

.predict-section {
  margin: 30px 0;
}

.predict-button {
  width: 100%;
  padding: 12px;
  font-size: 1.1rem;
  font-weight: 600;
  transition: all 0.3s ease;
  
  &.collapsed {
    width: 48px;
    height: 48px;
    padding: 0;
    min-width: unset;
    border-radius: 50%;
    
    mat-icon {
      margin: 0;
    }
  }
  
  mat-icon {
    margin-right: 8px;
  }
}

.quick-action {
  width: 100%;
  margin-bottom: 10px;
  justify-content: flex-start;
  
  mat-icon {
    margin-right: 10px;
    color: #667eea;
  }
}
EOF

# Dashboard Component
cat > src/app/components/dashboard/dashboard.component.ts << 'EOF'
import { Component, OnInit } from '@angular/core';
import { DataService } from '../../services/data.service';
import { Product } from '../../models/product.model';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnInit {
  selectedProduct: Product | null = null;
  showPrediction: boolean = false;
  isLoading: boolean = false;
  allProducts: Product[] = [];

  constructor(private dataService: DataService) {}

  ngOnInit(): void {
    this.allProducts = this.dataService.getAllProducts();
  }

  onPredict(): void {
    this.isLoading = true;
    this.showPrediction = true;
    
    setTimeout(() => {
      this.selectedProduct = this.dataService.getMockProduct();
      this.isLoading = false;
    }, 1000);
  }

  onAnalyze(): void {
    if (this.selectedProduct) {
      this.isLoading = true;
      
      setTimeout(() => {
        this.isLoading = false;
        alert(`Análisis completado para ${this.selectedProduct?.name}`);
      }, 1500);
    }
  }
}
EOF

cat > src/app/components/dashboard/dashboard.component.html << 'EOF'
<div class="dashboard-container">
  <!-- Sidebar -->
  <app-sidebar (predict)="onPredict()"></app-sidebar>

  <!-- Main Content -->
  <div class="main-content">
    <!-- Loading Overlay -->
    <div *ngIf="isLoading" class="loading-overlay">
      <mat-spinner diameter="50"></mat-spinner>
      <p>Procesando predicción...</p>
    </div>

    <!-- Welcome Banner -->
    <div class="welcome-banner" *ngIf="!showPrediction">
      <div class="banner-content">
        <h1>Bienvenido a Kommerco Analytics</h1>
        <p>Sistema predictivo para productos de papelería</p>
        <p class="banner-subtitle">Seleccione un producto y presione "Predecir" para comenzar</p>
      </div>
    </div>

    <!-- Product Cards -->
    <div *ngIf="showPrediction && selectedProduct" class="product-cards-container">
      <div class="section-header">
        <h2>Datos del Producto</h2>
        <p>Información actual y métricas clave</p>
      </div>
      
      <div class="cards-grid">
        <app-product-card 
          [product]="selectedProduct"
          [showAnalysis]="true">
        </app-product-card>
      </div>
    </div>

    <!-- Predictive Analysis Section -->
    <div *ngIf="showPrediction" class="predictive-section">
      <div class="section-header">
        <h2>Análisis Predictivo de Productos</h2>
        <p>Seleccione un producto y genere proyecciones</p>
      </div>

      <div class="analysis-controls">
        <mat-form-field appearance="outline" class="product-selector">
          <mat-label>Seleccionar Producto</mat-label>
          <mat-select [(value)]="selectedProduct">
            <mat-option [value]="selectedProduct">{{selectedProduct?.name}}</mat-option>
          </mat-select>
          <mat-icon matSuffix>inventory_2</mat-icon>
        </mat-form-field>

        <button mat-raised-button color="primary" class="analyze-button" (click)="onAnalyze()">
          <mat-icon>analytics</mat-icon>
          Analizar Producto
        </button>
      </div>

      <!-- Detailed Predictive Analysis -->
      <div class="detailed-analysis">
        <div class="section-header">
          <h3>Análisis Predictivo Detallado</h3>
          <p>Proyección de demanda para las próximas 16 semanas</p>
        </div>

        <div class="chart-container">
          <app-predictive-chart></app-predictive-chart>
        </div>

        <!-- Additional Metrics -->
        <div class="metrics-grid">
          <div class="metric-card">
            <div class="metric-header">
              <mat-icon>trending_up</mat-icon>
              <h4>Tendencia</h4>
            </div>
            <div class="metric-value positive">+12.5%</div>
            <p class="metric-label">Crecimiento semanal</p>
          </div>

          <div class="metric-card">
            <div class="metric-header">
              <mat-icon>show_chart</mat-icon>
              <h4>Demanda Máxima</h4>
            </div>
            <div class="metric-value">1,250 unidades</div>
            <p class="metric-label">Semana 8 proyectada</p>
          </div>

          <div class="metric-card">
            <div class="metric-header">
              <mat-icon>compare</mat-icon>
              <h4>Confianza</h4>
            </div>
            <div class="metric-value">94.2%</div>
            <p class="metric-label">Nivel de precisión</p>
          </div>

          <div class="metric-card">
            <div class="metric-header">
              <mat-icon>warning</mat-icon>
              <h4>Recomendación</h4>
            </div>
            <div class="metric-value warning">Aumentar stock</div>
            <p class="metric-label">Inventario insuficiente</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
EOF

cat > src/app/components/dashboard/dashboard.component.scss << 'EOF'
.dashboard-container {
  display: flex;
  min-height: calc(100vh - 64px);
}

.main-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background-color: #f5f7fa;
}

.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  z-index: 1001;
  
  p {
    margin-top: 20px;
    color: #333;
    font-size: 1.1rem;
  }
}

.welcome-banner {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px;
  padding: 40px;
  color: white;
  text-align: center;
  margin-bottom: 30px;
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
}

.banner-content {
  max-width: 600px;
  margin: 0 auto;
  
  h1 {
    font-size: 2.5rem;
    margin-bottom: 15px;
    font-weight: 700;
  }
  
  p {
    font-size: 1.2rem;
    opacity: 0.9;
    margin-bottom: 10px;
  }
  
  .banner-subtitle {
    font-size: 1rem;
    opacity: 0.8;
    margin-top: 20px;
  }
}

.section-header {
  margin-bottom: 30px;
  
  h2 {
    color: #2d3748;
    font-size: 1.8rem;
    margin-bottom: 8px;
  }
  
  h3 {
    color: #4a5568;
    font-size: 1.4rem;
    margin-bottom: 8px;
  }
  
  p {
    color: #718096;
    font-size: 1rem;
  }
}

.product-cards-container {
  margin-bottom: 40px;
}

.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 20px;
}

.predictive-section {
  background: white;
  border-radius: 12px;
  padding: 30px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.analysis-controls {
  display: flex;
  gap: 20px;
  margin-bottom: 40px;
  align-items: flex-end;
}

.product-selector {
  flex: 1;
  max-width: 400px;
}

.analyze-button {
  height: 56px;
  padding: 0 24px;
  
  mat-icon {
    margin-right: 8px;
  }
}

.detailed-analysis {
  margin-top: 40px;
}

.chart-container {
  background: white;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 30px;
  border: 1px solid #e2e8f0;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-top: 30px;
}

.metric-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  border: 1px solid #e2e8f0;
  transition: transform 0.3s ease;
  
  &:hover {
    transform: translateY(-5px);
    box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
  }
}

.metric-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 15px;
  
  mat-icon {
    color: #667eea;
    font-size: 24px;
  }
  
  h4 {
    color: #4a5568;
    margin: 0;
    font-size: 1rem;
  }
}

.metric-value {
  font-size: 1.8rem;
  font-weight: 700;
  color: #2d3748;
  margin-bottom: 5px;
  
  &.positive {
    color: #38a169;
  }
  
  &.warning {
    color: #dd6b20;
  }
}

.metric-label {
  color: #718096;
  font-size: 0.9rem;
  margin: 0;
}
EOF

# Product Card Component
cat > src/app/components/product-card/product-card.component.ts << 'EOF'
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
EOF

cat > src/app/components/product-card/product-card.component.html << 'EOF'
<mat-card class="product-card" *ngIf="product">
  <mat-card-header>
    <div class="card-header">
      <div>
        <mat-card-title>{{ product.name }}</mat-card-title>
        <mat-card-subtitle>{{ product.id }} • {{ product.category }}</mat-card-subtitle>
      </div>
      <div class="stock-badge" [class]="getStockStatus().color">
        {{ getStockStatus().text }}
      </div>
    </div>
  </mat-card-header>

  <mat-card-content>
    <div class="product-metrics">
      <div class="metric">
        <div class="metric-label">Stock Actual</div>
        <div class="metric-value">{{ product.currentStock | number }}</div>
        <div class="metric-unit">unidades</div>
      </div>
      
      <div class="metric">
        <div class="metric-label">Demanda Semanal</div>
        <div class="metric-value">{{ product.weeklyDemand | number }}</div>
        <div class="metric-unit">unidades</div>
      </div>
      
      <div class="metric">
        <div class="metric-label">Precio</div>
        <div class="metric-value">{{ product.price | currency:'USD':'symbol':'1.2-2' }}</div>
        <div class="metric-unit">por unidad</div>
      </div>
      
      <div class="metric">
        <div class="metric-label">Tendencia</div>
        <div class="metric-value trend" [class]="getDemandTrend().color">
          <mat-icon>{{ getDemandTrend().icon }}</mat-icon>
          {{ getDemandTrend().text }}
        </div>
      </div>
    </div>

    <!-- Analysis Section -->
    <div *ngIf="showAnalysis" class="analysis-section">
      <mat-divider></mat-divider>
      
      <div class="analysis-metrics">
        <div class="analysis-metric">
          <mat-icon>schedule</mat-icon>
          <div>
            <div class="analysis-label">Tiempo de Entrega</div>
            <div class="analysis-value">{{ product.leadTime || 7 }} días</div>
          </div>
        </div>
        
        <div class="analysis-metric">
          <mat-icon>inventory_2</mat-icon>
          <div>
            <div class="analysis-label">Stock Seguridad</div>
            <div class="analysis-value">{{ product.safetyStock || 200 }} unidades</div>
          </div>
        </div>
        
        <div class="analysis-metric">
          <mat-icon>update</mat-icon>
          <div>
            <div class="analysis-label">Último Pedido</div>
            <div class="analysis-value">{{ product.lastOrderDate || '2024-01-15' }}</div>
          </div>
        </div>
      </div>
    </div>
  </mat-card-content>

  <mat-card-actions *ngIf="showAnalysis">
    <button mat-button color="primary">
      <mat-icon>edit</mat-icon>
      Editar
    </button>
    <button mat-button color="warn">
      <mat-icon>warning</mat-icon>
      Alerta Stock
    </button>
    <button mat-button color="accent">
      <mat-icon>analytics</mat-icon>
      Detalles
    </button>
  </mat-card-actions>
</mat-card>
EOF

cat > src/app/components/product-card/product-card.component.scss << 'EOF'
.product-card {
  height: 100%;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  
  &:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  width: 100%;
  
  mat-card-title {
    font-size: 1.2rem;
    font-weight: 600;
    color: #2d3748;
    margin-bottom: 4px;
  }
  
  mat-card-subtitle {
    color: #718096;
    font-size: 0.9rem;
  }
}

.stock-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  
  &.error {
    background-color: #fed7d7;
    color: #c53030;
  }
  
  &.warning {
    background-color: #feebc8;
    color: #c05621;
  }
  
  &.success {
    background-color: #c6f6d5;
    color: #276749;
  }
  
  &.info {
    background-color: #bee3f8;
    color: #2c5282;
  }
  
  &.gray {
    background-color: #e2e8f0;
    color: #4a5568;
  }
}

.product-metrics {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin: 20px 0;
}

.metric {
  text-align: center;
  padding: 15px;
  background: #f7fafc;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  
  .metric-label {
    font-size: 0.85rem;
    color: #718096;
    margin-bottom: 8px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }
  
  .metric-value {
    font-size: 1.8rem;
    font-weight: 700;
    color: #2d3748;
    margin-bottom: 4px;
    
    &.trend {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      font-size: 1rem;
      
      mat-icon {
        font-size: 20px;
      }
      
      &.error {
        color: #c53030;
      }
      
      &.warning {
        color: #dd6b20;
      }
      
      &.success {
        color: #38a169;
      }
      
      &.info {
        color: #3182ce;
      }
      
      &.gray {
        color: #718096;
      }
    }
  }
  
  .metric-unit {
    font-size: 0.8rem;
    color: #a0aec0;
  }
}

.analysis-section {
  margin-top: 20px;
}

.analysis-metrics {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 15px;
  margin-top: 20px;
}

.analysis-metric {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f8fafc;
  border-radius: 8px;
  
  mat-icon {
    color: #667eea;
    font-size: 24px;
  }
  
  .analysis-label {
    font-size: 0.8rem;
    color: #718096;
    margin-bottom: 2px;
  }
  
  .analysis-value {
    font-size: 0.95rem;
    font-weight: 600;
    color: #2d3748;
  }
}

mat-card-actions {
  display: flex;
  justify-content: space-between;
  padding: 16px !important;
  border-top: 1px solid #e2e8f0;
  
  button {
    mat-icon {
      margin-right: 8px;
      font-size: 18px;
    }
  }
}
EOF

# Predictive Chart Component
cat > src/app/components/charts/predictive-chart.component.ts << 'EOF'
import { Component, OnInit } from '@angular/core';
import { ChartComponent } from 'ng-apexcharts';
import { ChartOptions } from '../../models/product.model';

@Component({
  selector: 'app-predictive-chart',
  templateUrl: './predictive-chart.component.html',
  styleUrls: ['./predictive-chart.component.scss']
})
export class PredictiveChartComponent implements OnInit {
  public chartOptions: Partial<ChartOptions>;

  constructor() {
    this.chartOptions = this.createChartOptions();
  }

  ngOnInit(): void {
    // Chart is initialized in constructor
  }

  private createChartOptions(): Partial<ChartOptions> {
    // Generate weeks for categories
    const historicalWeeks = Array.from({ length: 12 }, (_, i) => `Semana ${i + 1}`);
    const predictionWeeks = Array.from({ length: 16 }, (_, i) => `S${i + 13}`);
    const allWeeks = [...historicalWeeks, ...predictionWeeks];
    
    // Generate data
    const historicalData = Array.from({ length: 12 }, (_, i) => 
      Math.floor(Math.random() * 400) + 200 + i * 15
    );
    
    const predictionData = Array.from({ length: 16 }, (_, i) => {
      const base = historicalData[11] + (i + 1) * 20;
      const variation = Math.random() * 100 - 50;
      return Math.max(0, Math.floor(base + variation));
    });

    return {
      series: [
        {
          name: 'Datos Históricos',
          data: [...historicalData, ...Array(16).fill(null)],
          color: '#3182CE'
        },
        {
          name: 'Predicción',
          data: [...Array(12).fill(null), ...predictionData.slice(0, 4)],
          color: '#38A169'
        },
        {
          name: 'Proyección 16 Semanas',
          data: [...Array(16).fill(null), ...predictionData],
          color: '#DD6B20',
          type: 'line',
          dashArray: 5
        }
      ],
      chart: {
        type: 'line',
        height: 400,
        toolbar: {
          show: true,
          tools: {
            download: true,
            selection: true,
            zoom: true,
            zoomin: true,
            zoomout: true,
            pan: true,
            reset: true
          }
        },
        zoom: {
          enabled: true
        }
      },
      dataLabels: {
        enabled: false
      },
      stroke: {
        curve: 'smooth',
        width: [3, 3, 4],
        dashArray: [0, 0, 5]
      },
      title: {
        text: 'Análisis Predictivo de Demanda',
        align: 'left',
        style: {
          fontSize: '16px',
          fontWeight: '600',
          color: '#2D3748'
        }
      },
      grid: {
        borderColor: '#E2E8F0',
        row: {
          colors: ['#F7FAFC', 'transparent'],
          opacity: 0.5
        }
      },
      markers: {
        size: 5,
        hover: {
          size: 7
        }
      },
      xaxis: {
        categories: allWeeks,
        labels: {
          style: {
            colors: '#718096',
            fontSize: '12px'
          }
        },
        axisBorder: {
          show: true,
          color: '#E2E8F0'
        },
        axisTicks: {
          show: true,
          color: '#E2E8F0'
        }
      },
      yaxis: {
        title: {
          text: 'Unidades Vendidas',
          style: {
            color: '#718096',
            fontSize: '12px',
            fontWeight: '600'
          }
        },
        labels: {
          style: {
            colors: '#718096',
            fontSize: '12px'
          }
        },
        min: 0
      },
      legend: {
        position: 'top',
        horizontalAlign: 'right',
        fontSize: '14px',
        fontFamily: 'Helvetica, Arial',
        fontWeight: 600,
        labels: {
          colors: '#4A5568'
        },
        itemMargin: {
          horizontal: 10,
          vertical: 5
        }
      },
      tooltip: {
        theme: 'light',
        x: {
          format: 'dd/MM/yy'
        }
      },
      annotations: {
        xaxis: [
          {
            x: 'Semana 12',
            borderColor: '#CBD5E0',
            label: {
              text: 'Inicio Predicción',
              style: {
                color: '#FFFFFF',
                background: '#3182CE',
                fontSize: '12px',
                fontWeight: '600',
                padding: {
                  left: 10,
                  right: 10,
                  top: 6,
                  bottom: 6
                }
              }
            }
          }
        ]
      }
    };
  }
}
EOF

cat > src/app/components/charts/predictive-chart.component.html << 'EOF'
<div class="chart-container">
  <div class="chart-header">
    <div>
      <h3>Demanda vs Predicción</h3>
      <p>Comparación entre datos históricos y proyecciones futuras</p>
    </div>
    <div class="chart-controls">
      <button mat-stroked-button>
        <mat-icon>download</mat-icon>
        Exportar
      </button>
      <button mat-stroked-button>
        <mat-icon>filter_list</mat-icon>
        Filtros
      </button>
    </div>
  </div>
  
  <div id="chart">
    <apx-chart 
      [series]="chartOptions.series"
      [chart]="chartOptions.chart"
      [xaxis]="chartOptions.xaxis"
      [yaxis]="chartOptions.yaxis"
      [stroke]="chartOptions.stroke"
      [dataLabels]="chartOptions.dataLabels"
      [grid]="chartOptions.grid"
      [markers]="chartOptions.markers"
      [title]="chartOptions.title"
      [legend]="chartOptions.legend"
      [tooltip]="chartOptions.tooltip"
      [annotations]="chartOptions.annotations">
    </apx-chart>
  </div>
  
  <div class="chart-footer">
    <div class="legend-info">
      <div class="legend-item">
        <div class="legend-color historical"></div>
        <span>Datos Históricos Reales</span>
      </div>
      <div class="legend-item">
        <div class="legend-color prediction"></div>
        <span>Predicción Basada en Histórico</span>
      </div>
      <div class="legend-item">
        <div class="legend-color projection"></div>
        <span>Proyección a 16 Semanas</span>
      </div>
    </div>
    <div class="accuracy-info">
      <mat-icon>verified</mat-icon>
      <span>Precisión del modelo: <strong>94.2%</strong></span>
    </div>
  </div>
</div>
EOF

cat > src/app/components/charts/predictive-chart.component.scss << 'EOF'
.chart-container {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  
  h3 {
    color: #2d3748;
    margin: 0;
    font-size: 1.4rem;
  }
  
  p {
    color: #718096;
    margin: 5px 0 0 0;
    font-size: 0.95rem;
  }
}

.chart-controls {
  display: flex;
  gap: 10px;
  
  button {
    mat-icon {
      margin-right: 8px;
      font-size: 18px;
    }
  }
}

#chart {
  margin: 20px 0;
}

.chart-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #e2e8f0;
}

.legend-info {
  display: flex;
  gap: 20px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
  
  .legend-color {
    width: 16px;
    height: 16px;
    border-radius: 3px;
    
    &.historical {
      background-color: #3182CE;
    }
    
    &.prediction {
      background-color: #38A169;
    }
    
    &.projection {
      background-color: #DD6B20;
    }
  }
  
  span {
    color: #4a5568;
    font-size: 0.9rem;
  }
}

.accuracy-info {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background-color: #c6f6d5;
  border-radius: 20px;
  
  mat-icon {
    color: #276749;
    font-size: 18px;
  }
  
  span {
    color: #276749;
    font-size: 0.9rem;
    
    strong {
      font-weight: 700;
    }
  }
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .chart-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }
  
  .chart-footer {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }
  
  .legend-info {
    flex-direction: column;
    gap: 10px;
  }
}
EOF

# 8. Styles Globales
echo "Actualizando styles.scss global..."

cat > src/styles.scss << 'EOF'
/* Import Angular Material theme */
@use '@angular/material' as mat;
@include mat.core();

$primary-palette: mat.define-palette(mat.$indigo-palette);
$accent-palette: mat.define-palette(mat.$teal-palette, A200, A100, A400);
$warn-palette: mat.define-palette(mat.$red-palette);

$theme: mat.define-light-theme((
  color: (
    primary: $primary-palette,
    accent: $accent-palette,
    warn: $warn-palette,
  ),
  typography: mat.define-typography-config(),
  density: 0,
));

@include mat.all-component-themes($theme);

/* Global styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body {
  height: 100%;
}

body {
  font-family: 'Roboto', 'Helvetica Neue', sans-serif;
  background-color: #f5f7fa;
  color: #333;
  line-height: 1.6;
}

.container {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

/* Custom scrollbar */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: #555;
}

/* Utility classes */
.text-center {
  text-align: center;
}

.mt-1 { margin-top: 4px; }
.mt-2 { margin-top: 8px; }
.mt-3 { margin-top: 16px; }
.mt-4 { margin-top: 24px; }
.mt-5 { margin-top: 32px; }

.mb-1 { margin-bottom: 4px; }
.mb-2 { margin-bottom: 8px; }
.mb-3 { margin-bottom: 16px; }
.mb-4 { margin-bottom: 24px; }
.mb-5 { margin-bottom: 32px; }

.p-1 { padding: 4px; }
.p-2 { padding: 8px; }
.p-3 { padding: 16px; }
.p-4 { padding: 24px; }
.p-5 { padding: 32px; }

.d-flex { display: flex; }
.align-center { align-items: center; }
.justify-between { justify-content: space-between; }
.justify-center { justify-content: center; }

.full-width {
  width: 100%;
}

/* Card styles */
.card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
  padding: 20px;
  margin-bottom: 20px;
}

/* Form styles */
.form-group {
  margin-bottom: 20px;
}

.form-label {
  display: block;
  margin-bottom: 8px;
  color: #4a5568;
  font-weight: 500;
}

/* Loading spinner overlay */
.loading-spinner {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.8);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
}

/* Responsive breakpoints */
@media (max-width: 768px) {
  .container {
    padding: 10px;
  }
  
  .card {
    padding: 15px;
  }
}

/* Print styles */
@media print {
  .no-print {
    display: none !important;
  }
}
EOF

# 9. Archivos de entorno
echo "Creando archivos de entorno..."

cat > src/environments/environment.ts << 'EOF'
export const environment = {
  production: false,
  appName: 'Kommerco Analytics',
  version: '1.0.0',
  apiUrl: 'http://localhost:3000/api',
  demoMode: true
};
EOF

cat > src/environments/environment.prod.ts << 'EOF'
export const environment = {
  production: true,
  appName: 'Kommerco Analytics',
  version: '1.0.0',
  apiUrl: 'https://api.kommerco.com/v1',
  demoMode: false
};
EOF

# 10. Index.html
echo "Actualizando index.html..."

cat > src/index.html << 'EOF'
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Kommerco - Predictive Analytics</title>
  <base href="/">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="icon" type="image/x-icon" href="favicon.ico">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
</head>
<body>
  <app-root></app-root>
</body>
</html>
EOF

# 11. Favicon (crear placeholder)
echo "Creando favicon placeholder..."
echo "Placeholder favicon" > src/favicon.ico

echo ""
echo "=== ESTRUCTURA COMPLETA CREADA ==="
echo ""
echo "Para instalar el proyecto:"
echo "1. Crear nuevo proyecto Angular:"
echo "   ng new stationery-predictive-analytics --routing --style=scss --skip-tests"
echo ""
echo "2. Reemplazar los archivos generados con los de este script"
echo ""
echo "3. Instalar dependencias exactas:"
echo "   npm install"
echo "   npm install @angular/material@16 @angular/cdk@16"
echo "   npm install apexcharts@3.44.0 ng-apexcharts@16"
echo ""
echo "4. Ejecutar la aplicación:"
echo "   ng serve --open"
echo ""
echo "La aplicación estará disponible en: http://localhost:4200"
echo "Credenciales demo: admin / admin123"
EOF