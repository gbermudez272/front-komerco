import { Component, ElementRef, ViewChild, AfterViewChecked } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';

interface ChatMessage {
  role: 'user' | 'aria';
  text: string;
  ts: number;
  pending?: boolean;
  error?: boolean;
}

@Component({
  selector: 'app-aria-chat',
  templateUrl: './aria-chat.component.html',
  styleUrls: ['./aria-chat.component.scss']
})
export class AriaChatComponent implements AfterViewChecked {
  @ViewChild('msgScroll') private msgScroll?: ElementRef<HTMLDivElement>;
  @ViewChild('msgInput') private msgInput?: ElementRef<HTMLTextAreaElement>;

  isOpen = false;
  messages: ChatMessage[] = [];
  draft = '';
  loading = false;

  private readonly endpoint = 'http://localhost:8000/aria/';
  private shouldScroll = false;

  constructor(private http: HttpClient) {}

  ngAfterViewChecked(): void {
    if (this.shouldScroll && this.msgScroll) {
      this.msgScroll.nativeElement.scrollTop = this.msgScroll.nativeElement.scrollHeight;
      this.shouldScroll = false;
    }
  }

  toggle(): void {
    this.isOpen = !this.isOpen;
    if (this.isOpen) {
      this.shouldScroll = true;
      setTimeout(() => this.msgInput?.nativeElement.focus(), 50);
    }
  }

  onKeydown(ev: KeyboardEvent): void {
    if (ev.key === 'Enter' && !ev.shiftKey) {
      ev.preventDefault();
      this.send();
    }
  }

  send(): void {
    const prompt = this.draft.trim();
    if (!prompt || this.loading) return;

    this.messages.push({ role: 'user', text: prompt, ts: Date.now() });
    this.draft = '';
    this.loading = true;
    this.shouldScroll = true;

    const placeholder: ChatMessage = { role: 'aria', text: '', ts: Date.now(), pending: true };
    this.messages.push(placeholder);

    const token = this.getSessionToken();
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Token ${token}` } : {})
    });

    this.http.post<any>(this.endpoint, { prompt }, { headers }).subscribe({
      next: (res) => {
        placeholder.text = this.extractAnswer(res);
        placeholder.pending = false;
        this.loading = false;
        this.shouldScroll = true;
      },
      error: (err) => {
        placeholder.text = this.formatError(err);
        placeholder.pending = false;
        placeholder.error = true;
        this.loading = false;
        this.shouldScroll = true;
      }
    });
  }

  clear(): void {
    if (this.loading) return;
    this.messages = [];
  }

  private getSessionToken(): string {
    return (
      localStorage.getItem('authToken') ||
      localStorage.getItem('sessionToken') ||
      localStorage.getItem('token') ||
      ''
    );
  }

  private extractAnswer(res: any): string {
    if (res == null) return '(sin respuesta)';
    if (typeof res === 'string') return res;
    return (
      res.response ?? res.answer ?? res.message ?? res.text ?? res.reply ??
      res.content ?? JSON.stringify(res)
    );
  }

  private formatError(err: any): string {
    if (err?.status === 0) return 'No se pudo conectar con Aria (¿está el servicio en localhost:8000?).';
    if (err?.status === 401 || err?.status === 403) return 'Sesión no válida. Vuelve a iniciar sesión.';
    const detail = err?.error?.detail || err?.error?.error || err?.message;
    return `Error ${err?.status || ''} ${detail ? '· ' + detail : ''}`.trim();
  }
}
