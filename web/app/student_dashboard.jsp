<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="tools.User" %>
<%@ page import="tools.CertDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    // 1. SECURITY: Ensure user is logged in
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    // 2. DATA FETCHING: Get certifications (Now pulling from PostgreSQL!)
    CertDAO certDAO = new CertDAO();
    List<Map<String, String>> certs = certDAO.getStudentCertifications(application, currentUser.getUsername());

    // 3. LOGIC: Calculate metrics (Initialize with 0 to prevent "non-existing" errors)
    int certCount = (certs != null) ? certs.size() : 0;
    double totalScore = 0;
    if (certs != null) {
        for (Map<String, String> cert : certs) {
            try {
                totalScore += Double.parseDouble(cert.get("score"));
            } catch (Exception e) {
                // Ignore parsing errors
            }
        }
    }
    double averageScore = (certCount > 0) ? (totalScore / certCount) : 0.0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal Dashboard - Certifications</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            /* NexaFlow Premium Palette Matrix */
            --bg-gradient: radial-gradient(circle at 50% 0%, #1e0b45 0%, #000000 100%);
            --card-bg: rgba(22, 16, 36, 0.65);
            --sidebar-bg: #090611;
            /* Accents */
            --accent-purple: #8B5CF6;
            --accent-teal: #2DD4BF;
            --accent-gold: #FBBF24;
            --border-glass: rgba(255, 255, 255, 0.06);
            --border-glass-top: rgba(255, 255, 255, 0.14);
            /* High Contrast Text Visibility Rules */
            --text-heading: #ffffff;
            --text-body: #e2e8f0;
            --text-muted: #94a3b8;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-gradient);
            background-attachment: fixed;
            color: var(--text-body);
            min-height: 100vh;
            margin: 0;
            position: relative;
        }

        /* Subtle SVG Noise Overlay */
        body::before {
            content: "";
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0.03;
            z-index: 1;
            pointer-events: none;
            background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)'/%3E%3C/svg%3E");
        }

        /* Sidebar Layout Construction */
        .sidebar {
            background-color: var(--sidebar-bg);
            border-right: 1px solid var(--border-glass);
            min-height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            width: 260px;
            padding-top: 1.75rem;
            z-index: 100;
            transition: transform 0.3s ease;
        }

        /* Desktop Main Content Layout */
        .main-content {
            margin-left: 260px;
            padding: 2.5rem;
            position: relative;
            z-index: 2;
        }

        .nav-link-custom {
            display: flex;
            align-items: center;
            padding: 0.8rem 1.25rem;
            color: var(--text-muted);
            text-decoration: none;
            border-radius: 12px;
            margin: 0.25rem 1.25rem;
            font-weight: 500;
            font-size: 0.95rem;
            transition: all 0.2s ease;
            border: 1px solid transparent;
        }

        .nav-link-custom:hover, .nav-link-custom.active {
            background-color: rgba(139, 92, 246, 0.1);
            color: #a78bfa;
        }

        .nav-link-custom.active {
            border: 1px solid rgba(139, 92, 246, 0.2);
            background-color: rgba(139, 92, 246, 0.15);
        }

        .nav-link-custom i {
            font-size: 1.2rem;
            margin-right: 0.85rem;
        }

        h4, h5, h6 {
            font-family: 'Plus Jakarta Sans', sans-serif;
            letter-spacing: -0.01em;
            color: var(--text-heading);
        }

        /* Bento Metric Architecture with Managed Underglow */
        .metric-card {
            background: var(--card-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--border-glass);
            border-top: 1px solid var(--border-glass-top);
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .metric-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.5), 0 0 20px rgba(139, 92, 246, 0.08);
        }

        .icon-box {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Interactive Exam Grid Elements */
        .exam-card {
            background: var(--card-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--border-glass);
            border-top: 1px solid var(--border-glass-top);
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
            height: 100%;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .exam-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.6), 0 0 25px rgba(139, 92, 246, 0.12);
        }

        .exam-img-container {
            height: 140px;
            background-color: rgba(255, 255, 255, 0.02);
            border-bottom: 1px solid var(--border-glass);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .exam-img-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.85;
            transition: opacity 0.2s ease;
        }

        .exam-card:hover .exam-img-container img {
            opacity: 1;
        }

        .exam-img-container i {
            opacity: 0.8;
        }

        /* Lists and Tables */
        .list-group-item {
            background-color: rgba(22, 16, 36, 0.4) !important;
            border: 1px solid var(--border-glass) !important;
            margin-bottom: 0.5rem;
            border-radius: 12px !important;
            color: var(--text-body) !important;
            transition: background-color 0.2s ease;
        }

        .list-group-item:hover {
            background-color: rgba(22, 16, 36, 0.7) !important;
        }

        .alert-light {
            background-color: rgba(255, 255, 255, 0.02) !important;
            border: 1px solid var(--border-glass) !important;
            color: var(--text-muted) !important;
            border-radius: 12px;
        }

        .badge-score {
            background-color: rgba(139, 92, 246, 0.15) !important;
            color: #c4b5fd !important;
            border: 1px solid rgba(139, 92, 246, 0.3);
            font-weight: 600;
        }

        /* Mobile View Header Strip CSS */
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

        /* Rules apply when viewport drops under 992px */
        @media (max-width: 991.98px) {
            .mobile-header-bar {
                display: flex;
            }
            .sidebar {
                transform: translateX(-100%); /* Hide sidebar offscreen on mobile */
                width: 280px;
                z-index: 1050;
            }
            /* Slide sidebar in when toggle class is attached via the hamburger click */
            .sidebar.drawer-active {
                transform: translateX(0);
            }
            .main-content {
                margin-left: 0; /* Clear desktop margin so cards fill 100% layout width */
                padding: 6.5rem 1.25rem 2.5rem 1.25rem;
            }
        }
    </style>
</head>
<body>

    <div class="mobile-header-bar">
        <div class="d-flex align-items-center">
            <i class="bi bi-mortarboard-fill fs-4 me-2" style="color: var(--accent-purple);"></i>
            <span class="fw-bold text-white">EduPortal</span>
        </div>
        <button class="btn btn-hamburger-toggle" type="button" onclick="handleSidebarDisplayToggle('toggle')">
            <i class="bi bi-list"></i>
        </button>
    </div>

    <aside class="sidebar" id="globalAppSidebarContainer">
        <div class="px-4 mb-4 d-flex align-items-center justify-content-between">
            <div class="d-flex align-items-center">
                <i class="bi bi-mortarboard-fill fs-4 me-2" style="color: var(--accent-purple);"></i>
                <span class="fw-bold fs-5 text-white">EduPortal</span>
            </div>
            <button type="button" class="btn-close btn-close-white d-lg-none" onclick="handleSidebarDisplayToggle(false)"></button>
        </div>
        <nav class="nav flex-column">
            <a class="nav-link-custom active" href="${pageContext.request.contextPath}/app/student_dashboard.jsp"><i class="bi bi-house-door-fill text-primary"></i> Dashboard</a>
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/takeExam"><i class="bi bi-pencil-square"></i> Take Exam</a>
            
            <hr class="mx-3 border-secondary border-opacity-50">
            
            <a class="nav-link-custom" href="${pageContext.request.contextPath}/settings.jsp"><i class="bi bi-gear-fill"></i> Account Settings</a>
            <a class="nav-link-custom text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-left"></i> Sign Out</a>
        </nav>
    </aside>

    <main class="main-content">
        <header class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
            <div>
                <h4 class="fw-bold m-0 text-white">Welcome Back, <%= currentUser.getUsername() %>!</h4>
                <p style="color: var(--text-muted);" class="small m-0">Here is your portal status snapshot summary.</p>
            </div>
            <div>
                <div class="d-flex align-items-center p-2 rounded-3 shadow-sm" style="background: rgba(255,255,255,0.03); border: 1px solid var(--border-glass);">
                    <div class="rounded-circle text-white d-flex align-items-center justify-content-center me-2" style="width: 32px; height: 32px; background: rgba(139, 92, 246, 0.2); color: var(--accent-purple) !important;">
                        <i class="bi bi-person-fill"></i>
                    </div>
                    <span class="small fw-semibold text-white me-2">Student Account</span>
                </div>
            </div>
        </header>

        <section class="row g-4 mb-5">
            <div class="col-12 col-sm-6 col-lg-4">
                <div class="card metric-card p-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <span style="color: var(--text-muted);" class="small fw-semibold text-uppercase">Active Exams</span>
                            <h3 class="fw-bold m-0 mt-1 text-white">12</h3>
                        </div>
                        <div class="icon-box" style="background-color: rgba(139, 92, 246, 0.12); color: #a78bfa;">
                            <i class="bi bi-file-earmark-text fs-4"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-lg-4">
                <div class="card metric-card p-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <span style="color: var(--text-muted);" class="small fw-semibold text-uppercase">Certifications</span>
                            <h3 class="fw-bold m-0 mt-1 text-white"><%= certCount %></h3>
                        </div>
                        <div class="icon-box" style="background-color: rgba(45, 212, 191, 0.12); color: var(--accent-teal);">
                            <i class="bi bi-patch-check fs-4"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-lg-4">
                <div class="card metric-card p-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <span style="color: var(--text-muted);" class="small fw-semibold text-uppercase">Overall Average</span>
                            <h3 class="fw-bold m-0 mt-1 text-white"><%= String.format("%.1f", averageScore) %>%</h3>
                        </div>
                        <div class="icon-box" style="background-color: rgba(251, 191, 36, 0.12); color: var(--accent-gold);">
                            <i class="bi bi-award fs-4"></i>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="mb-5">
            <h5 class="fw-bold mb-4 text-white">Your Earned Certifications</h5>
            <% if (certs == null || certs.isEmpty()) { %>
                <div class="alert alert-light text-center p-4">
                    <i class="bi bi-patch-question fs-3 d-block mb-2 text-muted"></i>
                    You haven't earned any certifications yet. Take an exam below to get started!
                </div>
            <% } else { %>
                <div class="list-group">
                    <% for (Map<String, String> cert : certs) { %>
                        <div class="list-group-item d-flex justify-content-between align-items-center p-3">
                            <div>
                                <h6 class="mb-1 fw-bold" style="color: var(--accent-teal);">
                                    <i class="bi bi-patch-check-fill me-2"></i><%= cert.get("course_code") %>
                                </h6>
                                <small style="color: var(--text-muted);">Issued: <%= cert.get("issue_date") %></small>
                            </div>
                            <span class="badge badge-score rounded-pill px-3 py-2 fs-6"><%= cert.get("score") %>%</span>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </section>
        
        <section class="mb-5 border-top pt-4 mt-5" style="border-color: var(--border-glass) !important;">
            <h5 class="fw-bold mb-4 text-white">Export Records</h5>
            <div class="row g-4">
                <div class="col-md-6">
                    <div class="card metric-card p-4 h-100 bg-transparent">
                        <div class="d-flex align-items-center mb-3">
                            <i class="bi bi-person-lines-fill fs-3 me-3" style="color: #0D6EFD;"></i>
                            <h6 class="fw-bold text-white m-0">Personal Account Record</h6>
                        </div>
                        <p class="text-white-50 small mb-4">Download a complete landscape PDF of your profile and exam history.</p>
                        <a href="${pageContext.request.contextPath}/generateReport?action=selfReport" class="btn btn-outline-primary btn-sm fw-bold w-100 py-2 mt-auto">
                            <i class="bi bi-download me-1"></i> Download My Record
                        </a>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="card metric-card p-4 h-100 bg-transparent">
                        <div class="d-flex align-items-center mb-3">
                            <i class="bi bi-award-fill fs-3 me-3" style="color: #8B5CF6;"></i>
                            <h6 class="fw-bold text-white m-0">Print Certificates</h6>
                        </div>
                        <p class="text-white-50 small mb-4">Generate official printable certificate cards for your completed courses.</p>
                        
                        <div class="mt-auto">
                            <% if (certCount > 0) { %>
                                <a href="${pageContext.request.contextPath}/generateReport?action=printCertificates" class="btn btn-sm fw-bold w-100 py-2" style="background-color: #8B5CF6; color: white;">
                                    <i class="bi bi-printer me-1"></i> Print Certificates
                                </a>
                            <% } else { %>
                                <button class="btn btn-sm fw-bold w-100 py-2 text-center" disabled style="background-color: rgba(255,255,255,0.06); color: rgba(255,255,255,0.25); border: 1px solid rgba(255,255,255,0.05); cursor: not-allowed;">
                                    <i class="bi bi-slash-circle me-1"></i> No Certificates Available
                                </button>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="mb-4">
            <h5 class="fw-bold mb-4 text-white">Available Certification Exams</h5>
            <div class="row g-4">
                
                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='${pageContext.request.contextPath}/takeExam?courseId=1&courseCode=JAVA101'">
                        <div class="exam-img-container">
                            <img src="${pageContext.request.contextPath}/images/image_58c1fe.png" alt="Java Web Development" onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                            <i class="bi bi-code-slash text-purple" style="font-size: 3.5rem; color: #a78bfa; display:none;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2 text-white">Java Web Development</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Master enterprise Java architectures, Servlet life cycles, and advanced JSP integrations.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Short Answer</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='${pageContext.request.contextPath}/takeExam?courseId=2&courseCode=DEV201'">
                        <div class="exam-img-container">
                            <img src="${pageContext.request.contextPath}/images/image_58c216.png" alt="DevOps Engineering" onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                            <i class="bi bi-infinity" style="font-size: 3.5rem; color: #2DD4BF; display:none;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2 text-white">DevOps Engineering</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Validate your knowledge in CI/CD pipelines, containerization, and infrastructure as code.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Short Answer</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='${pageContext.request.contextPath}/takeExam?courseId=3&courseCode=PYT301'">
                        <div class="exam-img-container" style="color: #38bdf8;">
                            <i class="bi bi-filetype-py" style="font-size: 3.5rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2 text-white">Python Programming</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Test your proficiency in Python algorithms, data structures, and object-oriented paradigms.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Short Answer</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </section>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // MODIFIED: Incorporating full dual state canvas check evaluations
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