// Ajuste este valor caso o backend esteja em outro host/porta.
//const API_BASE = '/sysrev/api'
const API_BASE = window.API_BASE_URL || 'http://localhost:9500/sysrev/api';
//const API_BASE = window.API_BASE_URL || 'https://labgira.com/sysrev/api'; 

function getToken() {
  return localStorage.getItem('prisma_token');
}

function setSession(token, user) {
  localStorage.setItem('prisma_token', token);
  localStorage.setItem('prisma_user', JSON.stringify(user));
}

function getUser() {
  const raw = localStorage.getItem('prisma_user');
  return raw ? JSON.parse(raw) : null;
}

function logout() {
  localStorage.removeItem('prisma_token');
  localStorage.removeItem('prisma_user');
  window.location.href = '/sysrev/index.html';
}

async function apiFetch(path, options = {}) {
  const token = getToken();
  const headers = {
    'Content-Type': 'application/json',
    ...(options.headers || {}),
  };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const response = await fetch(`${API_BASE}${path}`, { ...options, headers });

  if (response.status === 401) {
    logout();
    throw new Error('Session expired. Login again.');
  }

  if (!response.ok) {
    let detail = 'Server error.';
    try {
      const body = await response.json();
      detail = body.detail || detail;
    } catch (_) { /* resposta sem corpo JSON */ }
    throw new Error(detail);
  }

  if (response.status === 204) return null;
  return response.json();
}

const api = {
  // Autenticação
  login: (email, password) =>
    apiFetch('/auth/login', { method: 'POST', body: JSON.stringify({ email, password }) }),
  
  register: (name, email, password) =>
    apiFetch('/auth/register', { method: 'POST', body: JSON.stringify({ name, email, password }) }),

  // Projetos
  listProjects: () => apiFetch('/projects'),
  
  getProject: (projectId) => 
    apiFetch(`/projects/${projectId}`), 
  
  createProject: (payload) => 
    apiFetch('/projects', { method: 'POST', body: JSON.stringify(payload) }),

  // Membros do Projeto
  listProjectMembers: (projectId) => 
    apiFetch(`/projects/${projectId}/members`),
  
  addProjectMember: (projectId, payload) =>
    apiFetch(`/projects/${projectId}/members`, { method: 'POST', body: JSON.stringify(payload) }), 

  // Metadados Globais (Países e Idiomas)
  getCountries: () => 
    apiFetch('/metadata/countries'), 
  
  getLanguages: () => 
    apiFetch('/metadata/languages'), 

  // Grupos de Trabalho Globais (Work Groups)
  getWorkGroups() {
    return apiFetch('/work-groups', { 
      method: 'GET' 
    });
  },

  // Usuários Globais do Sistema (para o campo de busca de membros)
  getUsers: () => 
    apiFetch('/users'), 

  // Dashboards
  dashboardAdmin: () => apiFetch('/dashboard/admin'),
  dashboardReviewer: () => apiFetch('/dashboard/reviewer'),

  // Atribuições (Assignments)
  listProjectAssignments: (projectId) => 
    apiFetch(`/projects/${projectId}/assignments`),
  
  myAssignments: (projectId) => 
    apiFetch(`/projects/${projectId}/assignments/my`),

  // Revisões (Reviews)
  getReview: (assignmentId) => 
    apiFetch(`/assignments/${assignmentId}/review`),
  
  saveReview: (assignmentId, payload) =>
    apiFetch(`/assignments/${assignmentId}/review`, { method: 'PUT', body: JSON.stringify(payload) }),

  // Conflitos (Conflicts)
  listConflicts: (projectId) => 
    apiFetch(`/projects/${projectId}/conflicts`),
  
  resolveConflict: (projectId, conflictId, payload) =>
    apiFetch(`/projects/${projectId}/conflicts/${conflictId}/resolve`, {
      method: 'PUT', 
      body: JSON.stringify(payload),
    }),

  deleteProject(projectId) {
    return apiFetch(`/projects/${projectId}`, {
      method: 'DELETE'
    });
  },

  deleteProjectMember(projectId, userId) {
    return apiFetch(`/projects/${projectId}/members/${userId}`, {
      method: 'DELETE'
    });
  },

  updateProject: (projectId, payload) => 
      apiFetch(`/projects/${projectId}`, { 
          method: 'PUT', // ou PATCH, dependendo do seu backend
          body: JSON.stringify(payload) 
      }),

  getProjectForm: (projectId) => 
    apiFetch(`/projects/${projectId}/forms`),

  saveProjectForm: (projectId, payload) => 
    apiFetch(`/projects/${projectId}/forms`, { 
      method: 'POST', 
      body: JSON.stringify(payload) // payload: { title, description, structure }
    }),

  submitFormResponse: (formId, payload) => 
    apiFetch(`/forms/${formId}/responses`, { 
      method: 'POST', 
      body: JSON.stringify(payload) // payload: { assignment_id, answers }
    }),

};
