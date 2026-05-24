<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="tools.User" %>
<%@ page import="java.util.List" %>
<%
    // Security check
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole().trim())) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    List<User> userList = (List<User>) request.getAttribute("userList");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>System Directory</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #f8f9fa; }
        .sidebar { background-color: #ffffff; border-right: 1px solid #e2e8f0; min-height: 100vh; position: fixed; width: 260px; padding-top: 1.5rem; }
        .main-content { margin-left: 260px; padding: 2rem; }
        .nav-link-custom { display: flex; align-items: center; padding: 0.75rem 1.25rem; color: #64748b; text-decoration: none; border-radius: 8px; margin: 0.25rem 1rem; font-weight: 500; }
        .nav-link-custom:hover { background-color: #f1f5f9; color: #8B5CF6; }
        .card-custom { background: #ffffff; border: none; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.02); padding: 2rem; }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="px-4 mb-4 d-flex align-items-center">
            <i class="bi bi-shield-lock-fill fs-3 me-2" style="color: #8B5CF6;"></i>
            <span class="fw-bold fs-5 text-dark">EduPortal Admin</span>
        </div>
        <nav class="nav flex-column">
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/admin_dashboard.jsp"><i class="bi bi-sliders"></i> Control Center</a>
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/reports.jsp"><i class="bi bi-file-earmark-bar-graph-fill"></i> System Reports</a>
            <hr class="mx-3 text-muted">
            <a class="nav-link-custom text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-left"></i> Sign Out</a>
        </nav>
    </aside>

    <main class="main-content">
        <header class="mb-4">
            <h4 class="fw-bold m-0">User Directory</h4>
            <p class="text-muted small m-0">Overview of all active accounts in the Derby identity database.</p>
        </header>

        <div class="card card-custom">
            <% if (userList == null || userList.isEmpty()) { %>
                <div class="alert alert-warning">No users found. Did you run the Seeder?</div>
            <% } else { %>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Username</th>
                                <th>System Role</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (User u : userList) { %>
                                <tr>
                                    <td class="fw-semibold"><i class="bi bi-person-circle text-secondary me-2"></i><%= u.getUsername() %></td>
                                    <td>
                                        <% if ("Admin".equalsIgnoreCase(u.getRole())) { %>
                                            <span class="badge bg-danger">Admin</span>
                                        <% } else { %>
                                            <span class="badge bg-primary">Student</span>
                                        <% } %>
                                    </td>
                                    <td><span class="text-success small fw-bold"><i class="bi bi-circle-fill me-1" style="font-size: 0.5rem;"></i>Active</span></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </div>
    </main>

</body>
</html>