export interface User {
  username: string;
  role: 'admin' | 'analyst' | 'viewer';
  name: string;
  email: string;
}
