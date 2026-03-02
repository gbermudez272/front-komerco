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
