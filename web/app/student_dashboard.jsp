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

    // 2. DATA FETCHING: Get certifications
    CertDAO certDAO = new CertDAO();
    // application is the ServletContext in JSP
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
        }

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

        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                min-height: auto;
                position: relative;
                border-right: none;
                border-bottom: 1px solid var(--border-glass);
                padding-bottom: 1rem;
            }
            .main-content {
                margin-left: 0;
                padding: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <aside class="sidebar">
        <div class="px-4 mb-4 d-flex align-items-center">
            <i class="bi bi-mortarboard-fill fs-4 me-2" style="color: var(--accent-purple);"></i>
            <span class="fw-bold fs-5 text-white">EduPortal</span>
        </div>
        <nav class="nav flex-column">
            <a class="nav-link-custom active" href="#"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a>
            <a class="nav-link-custom" href="#"><i class="bi bi-journal-text"></i> Exams</a>
            <a class="nav-link-custom" href="#"><i class="bi bi-bar-chart-line"></i> Performance</a>
            <a class="nav-link-custom" href="#"><i class="bi bi-gear"></i> Settings</a>
            <hr class="mx-3 opacity-20" style="color: var(--text-muted);">
            <a class="nav-link-custom text-danger" href="logout"><i class="bi bi-box-arrow-left"></i> Sign Out</a>
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
                                    <i class="bi bi-patch-check-fill me-2"></i><%= cert.get("course_name") %>
                                </h6>
                                <small style="color: var(--text-muted);">Issued: <%= cert.get("issue_date") %></small>
                            </div>
                            <span class="badge badge-score rounded-pill px-3 py-2 fs-6"><%= cert.get("score") %>%</span>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </section>

        <section class="mb-4">
            <h5 class="fw-bold mb-4 text-white">Available Certification Exams</h5>
            <div class="row g-4">
                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=1'">
                        <div class="exam-img-container">
                            <img src="${pageContext.request.contextPath}/images/image_58c1fe.png" alt="Java Web Development" onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                            <i class="bi bi-code-slash text-purple" style="font-size: 3.5rem; color: #a78bfa; display:none;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">Java Web Development</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Master enterprise Java architectures, Servlet life cycles, and advanced JSP integrations.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=2'">
                        <div class="exam-img-container">
                            <img src="${pageContext.request.contextPath}/images/image_58c216.png" alt="DevOps Engineering" onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                            <i class="bi bi-infinity" style="font-size: 3.5rem; color: #2DD4BF; display:none;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">DevOps Engineering</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Validate your knowledge in CI/CD pipelines, containerization, and infrastructure as code.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=3'">
                        <div class="exam-img-container" style="color: #38bdf8;">
                            <i class="bi bi-filetype-py" style="font-size: 3.5rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">Python Programming</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Test your proficiency in Python algorithms, data structures, and object-oriented paradigms.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=4'">
                        <div class="exam-img-container" style="color: var(--accent-gold);">
                            <i class="bi bi-arrow-repeat" style="font-size: 3.5rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">Agile ScrumMaster</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Official evaluation covering Agile methodologies, sprint planning, and Scrum ceremonies.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=5'">
                        <div class="exam-img-container" style="color: #4ade80;">
                            <i class="bi bi-diagram-3-fill" style="font-size: 3.5rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">ITIL 4 Foundation</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Demonstrate understanding of modern IT service management and organizational value delivery.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=6'">
                        <div class="exam-img-container" style="color: #f87171;">
                            <i class="bi bi-shield-lock-fill" style="font-size: 3.5rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">Cybersecurity Fundamentals</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Assess your knowledge of threat vectors, network defense mechanisms, and access control.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=7'">
                        <div class="exam-img-container" style="color: #c084fc;">
                            <i class="bi bi-pc-display" style="font-size: 3.5rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">CompTIA A+ Certification</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Prove your ability to support IT enterprise systems by validating hardware, networks, and OS metrics.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=8'">
                        <div class="exam-img-container" style="color: #f97316;">
                            <i class="bi bi-fingerprint" style="font-size: 3.5rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">CompTIA Security+</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Validate the baseline skills necessary to improve global network resilience operations.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=9'">
                        <div class="exam-img-container" style="color: #22d3ee;">
                            <i class="bi bi-cpu" style="font-size: 3.5rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">CompTIA Tech+</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">An entry-level certification validating foundational knowledge covering cloud storage concepts.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=10'">
                        <div class="exam-img-container" style="color: #facc15;">
                            <i class="bi bi-bar-chart-steps" style="font-size: 3.5rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">Microsoft Power BI Analyst</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Learn to clean, transform, and map corporate metrics into readable value streams.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=11'">
                        <div class="exam-img-container" style="color: #6366f1;">
                            <i class="bi bi-cloud-arrow-up-fill" style="font-size: 3.5rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">Microsoft Azure Fundamentals</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Prove your foundational knowledge regarding core enterprise cloud platform components.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=12'">
                        <div class="exam-img-container" style="color: #a78bfa;">
                            <i class="bi bi-database-fill-gear" style="font-size: 3.5rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">SQL for Data Analysis</h6>
                            <p style="color: var(--text-muted);" class="small mb-4 flex-grow-1">Write optimized subqueries, execute aggregations, and query relational data nodes.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-dark border text-white small" style="border-color: var(--border-glass) !important;"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="fw-semibold small" style="color: var(--accent-purple);">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>