<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="tools.User" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    List<User> userList = (List<User>) request.getAttribute("userList");
%>
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <title>System Directory</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --bg-gradient: radial-gradient(circle at 50% 0%, #1a103c 0%, #000000 100%);
            --card-bg: rgba(26, 18, 44, 0.6);
            --sidebar-bg: #070512;
            --accent-purple: #8B5CF6;
            --accent-teal: #2DD4BF;
            --border-glass: rgba(255, 255, 255, 0.05);
            --border-glass-top: rgba(255, 255, 255, 0.12);
            --text-heading: #ffffff;
            --text-body: #cbd5e1;
            --text-muted: #64748b;
        }

        body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg-gradient); background-attachment: fixed; color: var(--text-body); min-height: 100vh; margin: 0; position: relative; }
        
        body::before {
            content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%; opacity: 0.03; z-index: 1; pointer-events: none;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E");
        }

        .sidebar { background-color: var(--sidebar-bg); border-right: 1px solid var(--border-glass); min-height: 100vh; position: fixed; top: 0; left: 0; width: 260px; padding-top: 1.75rem; z-index: 100; transition: transform 0.3s ease; }
        .main-content { margin-left: 260px; padding: 2.5rem; position: relative; z-index: 2; }
        
        .nav-link-custom { display: flex; align-items: center; padding: 0.8rem 1.25rem; color: var(--text-muted); text-decoration: none; border-radius: 12px; margin: 0.25rem 1.25rem; font-weight: 500; font-size: 0.95rem; transition: all 0.2s ease; border: 1px solid transparent; }
        .nav-link-custom:hover, .nav-link-custom.active { background-color: rgba(139, 92, 246, 0.08); color: #a78bfa; }
        .nav-link-custom.active { border: 1px solid rgba(139, 92, 246, 0.2); background-color: rgba(139, 92, 246, 0.12); }
        .nav-link-custom i { font-size: 1.2rem; margin-right: 0.85rem; }

        h4, h5, h6 { color: var(--text-heading); }

        .bento-card { background: var(--card-bg); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid var(--border-glass); border-top: 1px solid var(--border-glass-top); border-radius: 20px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4); padding: 2.25rem; }
        
        .btn-action-panel { background-color: rgba(255, 255, 255, 0.03); border: 1px solid var(--border-glass); border-radius: 8px; padding: 0.4rem 0.75rem; font-size: 0.85rem; font-weight: 600; color: #cbd5e1; transition: all 0.2s ease; text-decoration: none; }
        .btn-action-panel:hover { background-color: rgba(255, 255, 255, 0.1); color: #fff; }

        /* Transparent Dark Table */
        .table { --bs-table-bg: transparent; --bs-table-color: var(--text-body); --bs-table-border-color: var(--border-glass); }
        .table th { color: #94a3b8; font-weight: 600; border-bottom: 1px solid var(--border-glass-top); }
        .table td { border-bottom: 1px solid var(--border-glass); }
        .table-hover tbody tr:hover { background-color: rgba(255, 255, 255, 0.02); }

        /* Transparent Inputs */
        .form-control, .form-select { background-color: rgba(255, 255, 255, 0.03); border: 1px solid var(--border-glass); color: white; }
        .form-control:focus, .form-select:focus { background-color: rgba(255, 255, 255, 0.06); border-color: var(--accent-purple); box-shadow: 0 0 0 0.25rem rgba(139, 92, 246, 0.25); color: white;}
        
        /* Modal Customization */
        .modal-content { background-color: #1a103c; border: 1px solid var(--border-glass-top); box-shadow: 0 20px 40px rgba(0,0,0,0.8); }
        .modal-header, .modal-footer { border-color: var(--border-glass); }

        /* Responsive Mobile Layouts */
        .mobile-header-bar {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; height: 70px;
            background-color: var(--sidebar-bg);
            border-bottom: 1px solid var(--border-glass);
            z-index: 1030;
            padding: 0 1.5rem;
            align-items: center;
            justify-content: space-between;
        }

        .btn-hamburger-toggle {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border-glass);
            color: #ffffff;
            border-radius: 8px;
            padding: 0.4rem 0.75rem;
            font-size: 1.25rem;
        }

        @media (max-width: 991.98px) {
            .mobile-header-bar { display: flex; }
            .sidebar { transform: translateX(-100%); width: 280px; z-index: 1050; }
            .sidebar.drawer-active { transform: translateX(0); }
            .main-content { margin-left: 0; padding: 6.5rem 1.25rem 2.5rem 1.25rem; }
        }
    </style>
</head>
<body>

    <div class="mobile-header-bar">
        <div class="d-flex align-items-center">
            <i class="bi bi-shield-lock-fill fs-4 me-2" style="color: #8B5CF6;"></i>
            <span class="fw-bold text-white">EduPortal Admin</span>
        </div>
        <button class="btn btn-hamburger-toggle" type="button" onclick="handleSidebarDisplayToggle('toggle')">
            <i class="bi bi-list"></i>
        </button>
    </div>

    <aside class="sidebar" id="globalAppSidebarContainer">
        <div class="px-4 mb-4 d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center">
                <i class="bi bi-shield-lock-fill fs-3 me-2" style="color: #8B5CF6;"></i>
                <span class="fw-bold fs-5 text-white">EduPortal Admin</span>
            </div>
            <button type="button" class="btn-close btn-close-white d-lg-none" onclick="handleSidebarDisplayToggle(false)"></button>
        </div>
        <nav class="nav flex-column">
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/app/admin_dashboard.jsp"><i class="bi bi-sliders"></i> Control Center</a>
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/app/reports.jsp"><i class="bi bi-file-earmark-bar-graph-fill"></i> System Reports</a>
            <a class="nav-link-custom active" href="${pageContext.request.contextPath}/directory"><i class="bi bi-people-fill"></i> User Directory</a>
            <hr class="mx-3 border-secondary border-opacity-50">
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/settings.jsp"><i class="bi bi-gear-fill"></i> Account Settings</a>
            <a class="nav-link-custom text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-left"></i> Sign Out</a>
        </nav>
    </aside>

    <main class="main-content">
        <div class="d-flex justify-content-between align-items-end mb-4 flex-wrap gap-3">
            <header>
                <h4 class="fw-bold m-0">User Directory</h4>
                <p class="text-muted small m-0">Create, edit, or remove system accounts.</p>
            </header>
            <button class="btn fw-bold px-4 py-2.5 rounded-3 shadow-sm" style="background-color: var(--accent-purple); color: white;" data-bs-toggle="modal" data-bs-target="#addUserModal">
                <i class="bi bi-person-plus-fill me-1"></i> Add New User
            </button>
        </div>

        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger small py-2 fw-semibold border-0 bg-danger bg-opacity-25 text-white"><%= request.getParameter("error") %></div>
        <% } %>
        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success small py-2 fw-semibold border-0 bg-success bg-opacity-25 text-white"><%= request.getParameter("success") %></div>
        <% } %>

        <div class="bento-card">
            <div class="table-responsive">
                <table class="table table-hover align-middle m-0">
                    <thead>
                        <tr>
                            <th class="py-3 text-secondary small fw-semibold border-top-0">USERNAME</th>
                            <th class="py-3 text-secondary small fw-semibold border-top-0">SYSTEM ROLE</th>
                            <th class="py-3 text-secondary small fw-semibold border-top-0 text-end">MANAGEMENT ACTIONS</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (userList != null) { for (User u : userList) { %>
                            <tr>
                                <td class="fw-bold text-white py-3"><i class="bi bi-person-circle text-muted me-2 fs-5 align-middle"></i><%= u.getUsername() %></td>
                                <td class="py-3">
                                    <% if ("Admin".equalsIgnoreCase(u.getRole())) { %>
                                        <span class="badge bg-danger bg-opacity-25 text-danger border border-danger border-opacity-50 px-2 py-1">Admin</span>
                                    <% } else { %>
                                        <span class="badge bg-primary bg-opacity-25 text-primary border border-primary border-opacity-50 px-2 py-1">Student</span>
                                    <% } %>
                                </td>
                                <td class="text-end py-3">
                                    <button class="btn-action-panel me-2" data-bs-toggle="modal" data-bs-target="#editRoleModal<%= u.getUsername() %>"><i class="bi bi-pencil-fill me-1"></i> Role</button>
                                    <button class="btn-action-panel me-2" data-bs-toggle="modal" data-bs-target="#resetPassModal<%= u.getUsername() %>"><i class="bi bi-key-fill text-warning me-1"></i> Reset</button>
                                    <button class="btn-action-panel text-danger border-danger border-opacity-50" data-bs-toggle="modal" data-bs-target="#deleteModal<%= u.getUsername() %>"><i class="bi bi-trash3-fill"></i></button>
                                </td>
                            </tr>
                        <% }} %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <% if (userList != null) { for (User u : userList) { %>
        <div class="modal fade" id="editRoleModal<%= u.getUsername() %>" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered"><div class="modal-content">
                <form action="${pageContext.request.contextPath}/adminAction" method="POST">
                    <input type="hidden" name="action" value="editRole">
                    <input type="hidden" name="targetUser" value="<%= u.getUsername() %>">
                    <div class="modal-header">
                        <h5 class="modal-title fw-bold">Edit Role: <%= u.getUsername() %></h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <label class="form-label small fw-semibold">Select System Role</label>
                        <select name="role" class="form-select p-2.5 rounded-3">
                            <option value="student" <%= "student".equalsIgnoreCase(u.getRole()) ? "selected" : "" %>>Student</option>
                            <option value="admin" <%= "admin".equalsIgnoreCase(u.getRole()) ? "selected" : "" %>>Admin</option>
                        </select>
                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn fw-bold py-2 w-100" style="background-color: var(--accent-purple); color: white;">Save Changes</button>
                    </div>
                </form>
            </div></div>
        </div>

        <div class="modal fade" id="resetPassModal<%= u.getUsername() %>" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered"><div class="modal-content">
                <form action="${pageContext.request.contextPath}/adminAction" method="POST">
                    <input type="hidden" name="action" value="resetPassword">
                    <input type="hidden" name="targetUser" value="<%= u.getUsername() %>">
                    <div class="modal-header">
                        <h5 class="modal-title fw-bold">Reset Password: <%= u.getUsername() %></h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <label class="form-label small fw-semibold">New Password</label>
                        <input type="text" name="newPassword" class="form-control p-2.5 rounded-3" required placeholder="Type new password...">
                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn btn-warning text-dark fw-bold py-2 w-100">Force Reset Password</button>
                    </div>
                </form>
            </div></div>
        </div>

        <div class="modal fade" id="deleteModal<%= u.getUsername() %>" tabindex="-1">
            <div class="modal-dialog modal-dialog-centered"><div class="modal-content border-danger border-opacity-50">
                <form action="${pageContext.request.contextPath}/adminAction" method="POST">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="targetUser" value="<%= u.getUsername() %>">
                    <div class="modal-header border-0">
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body text-center pb-4">
                        <i class="bi bi-exclamation-circle-fill text-danger mb-3 d-block" style="font-size: 3.5rem;"></i>
                        <h5 class="fw-bold">Delete <%= u.getUsername() %>?</h5>
                        <p class="text-muted small px-3">This will permanently purge this identity and all earned certificates from the databases.</p>
                        <button type="submit" class="btn btn-danger fw-bold w-100 py-2.5 rounded-3 mt-2">Yes, Permanently Delete</button>
                    </div>
                </form>
            </div></div>
        </div>
    <% }} %>

    <div class="modal fade" id="addUserModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered"><div class="modal-content">
            <form action="${pageContext.request.contextPath}/adminAction" method="POST">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">Create New Account</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-light">Username</label>
                        <input type="text" name="targetUser" class="form-control p-2.5 rounded-3" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-light">Initial Password</label>
                        <input type="text" name="password" class="form-control p-2.5 rounded-3" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold text-light">System Role</label>
                        <select name="role" class="form-select p-2.5 rounded-3">
                            <option value="student">Student</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn fw-bold w-100 py-2.5 rounded-3" style="background-color: var(--accent-purple); color: white;">Provision Account</button>
                </div>
            </form>
        </div></div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function handleSidebarDisplayToggle(actionState) {
            const sidebar = document.getElementById('globalAppSidebarContainer');
            if (!sidebar) return;
            
            if (actionState === 'toggle') {
                if (sidebar.classList.contains('drawer-active')) {
                    sidebar.classList.remove('drawer-active');
                } else {
                    sidebar.classList.add('drawer-active');
                }
            } else if (actionState === true) {
                sidebar.classList.add('drawer-active');
            } else {
                sidebar.classList.remove('drawer-active');
            }
        }
    </script>
</body>
</html>