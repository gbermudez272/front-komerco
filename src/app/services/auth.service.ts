import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, of } from 'rxjs';
import { catchError, map, tap } from 'rxjs/operators';

interface LoginResponse {
  token: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly LOGIN_URL = 'http://localhost:8000/login/';
  private readonly TOKEN_KEY = 'authToken';
  private readonly USER_KEY  = 'authUser';

  constructor(private http: HttpClient, private router: Router) {}

  /** Llama al endpoint real de login. Si responde con token, lo guarda y resuelve true. */
  login(username: string, password: string): Observable<boolean> {
    return this.http.post<LoginResponse>(this.LOGIN_URL, { username, password }).pipe(
      tap(res => {
        if (res?.token) {
          localStorage.setItem(this.TOKEN_KEY, res.token);
          localStorage.setItem(this.USER_KEY, username);
          localStorage.setItem('isLoggedIn', 'true');
        }
      }),
      map(res => !!res?.token),
      catchError(() => of(false))
    );
  }

  logout(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    localStorage.removeItem(this.USER_KEY);
    localStorage.removeItem('isLoggedIn');
    this.router.navigate(['/login']);
  }

  isLoggedIn(): boolean {
    return !!localStorage.getItem(this.TOKEN_KEY);
  }

  getToken(): string {
    return localStorage.getItem(this.TOKEN_KEY) || '';
  }

  getUsername(): string {
    return localStorage.getItem(this.USER_KEY) || '';
  }
}
