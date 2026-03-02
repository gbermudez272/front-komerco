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
