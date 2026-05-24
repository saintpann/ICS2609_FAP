<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="tools.User" %>
<%
    // Security check: ensure user is logged in
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal Dashboard - Certifications</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: #f8f9fa;
            min-height: 100vh;
        }
        
        /* Sidebar Layout styling */
        .sidebar {
            background-color: #ffffff;
            border-right: 1px solid #e2e8f0;
            min-height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            width: 260px;
            padding-top: 1.5rem;
            z-index: 100;
        }
        
        /* Main Panel spacing offset by sidebar width */
        .main-content {
            margin-left: 260px;
            padding: 2rem;
        }
        
        .nav-link-custom {
            display: flex;
            align-items: center;
            padding: 0.75rem 1.25rem;
            color: #64748b;
            text-decoration: none;
            border-radius: 8px;
            margin: 0.25rem 1rem;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        
        .nav-link-custom:hover, .nav-link-custom.active {
            background-color: #f1f5f9;
            color: #8B5CF6;
        }
        
        .nav-link-custom i {
            font-size: 1.25rem;
            margin-right: 0.75rem;
        }

        /* Dashboard Metric Bento Cards */
        .metric-card {
            background: #ffffff;
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        
        .metric-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
        }
        
        .icon-box {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Exam Certification Cards */
        .exam-card {
            background: #ffffff;
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            cursor: pointer;
            height: 100%;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .exam-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(139, 92, 246, 0.15);
        }

        .exam-img-container {
            height: 150px;
            background-color: #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .exam-img-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                min-height: auto;
                position: relative;
            }
            .main-content {
                margin-left: 0;
                padding: 1rem;
            }
        }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="px-4 mb-4 d-flex align-items-center">
            <i class="bi bi-mortarboard-fill text-primary fs-3 me-2" style="color: #8B5CF6 !important;"></i>
            <span class="fw-bold fs-5 text-dark">EduPortal</span>
        </div>
        
        <nav class="nav flex-column">
            <a class="nav-link-custom active" href="#"><i class="bi bi-grid-1x2-fill"></i> Dashboard</a>
            <a class="nav-link-custom" href="#"><i class="bi bi-journal-text"></i> Exams</a>
            <a class="nav-link-custom" href="#"><i class="bi bi-bar-chart-line"></i> Performance</a>
            <a class="nav-link-custom" href="#"><i class="bi bi-gear"></i> Settings</a>
            <hr class="mx-3 text-muted">
            <a class="nav-link-custom text-danger" href="${pageContext.request.contextPath}/login.jsp"><i class="bi bi-box-arrow-left"></i> Sign Out</a>
        </nav>
    </aside>

    <main class="main-content">
        <header class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold m-0">Welcome Back, <%= currentUser.getUsername() %>!</h4>
                <p class="text-muted small m-0">Here is your portal status snapshot summary.</p>
            </div>
            <div class="dropdown">
                <div class="d-flex align-items-center bg-white p-2 rounded-3 border shadow-sm">
                    <div class="bg-secondary rounded-circle text-white d-flex align-items-center justify-content-center me-2" style="width: 32px; height: 32px;">
                        <i class="bi bi-person-fill"></i>
                    </div>
                    <span class="small fw-semibold me-2">Account</span>
                </div>
            </div>
        </header>

        <section class="row g-4 mb-5">
            <div class="col-12 col-sm-6 col-lg-4">
                <div class="card metric-card p-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">Active Exams</span>
                            <h3 class="fw-bold m-0 mt-1">12</h3>
                        </div>
                        <div class="icon-box" style="background-color: rgba(139, 92, 246, 0.1); color: #8B5CF6;">
                            <i class="bi bi-file-earmark-text fs-4"></i>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="col-12 col-sm-6 col-lg-4">
                <div class="card metric-card p-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">Certifications</span>
                            <h3 class="fw-bold m-0 mt-1">0</h3>
                        </div>
                        <div class="icon-box" style="background-color: rgba(45, 212, 191, 0.1); color: #2DD4BF;">
                            <i class="bi bi-patch-check fs-4"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-12 col-sm-6 col-lg-4">
                <div class="card metric-card p-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">Overall Average</span>
                            <h3 class="fw-bold m-0 mt-1">--%</h3>
                        </div>
                        <div class="icon-box" style="background-color: rgba(251, 191, 36, 0.1); color: #FBBF24;">
                            <i class="bi bi-award fs-4"></i>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section>
            <h5 class="fw-bold mb-4">Available Certification Exams</h5>
            <div class="row g-4">
                
                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=1'">
                        <div class="exam-img-container">
                            <img src="${pageContext.request.contextPath}/images/image_58c1fe.png" alt="Java Web Development">
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">Java Web Development</h6>
                            <p class="text-muted small mb-4 flex-grow-1">Master enterprise Java architectures, Servlet life cycles, and advanced JSP integrations.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-light text-dark border"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="text-primary fw-semibold small">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=2'">
                        <div class="exam-img-container">
                            <img src="${pageContext.request.contextPath}/images/image_58c216.png" alt="DevOps Engineering">
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">DevOps Engineering</h6>
                            <p class="text-muted small mb-4 flex-grow-1">Validate your knowledge in CI/CD pipelines, containerization, and infrastructure as code.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-light text-dark border"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="text-primary fw-semibold small">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=3'">
                        <div class="exam-img-container" style="background-color: #e0f2fe; color: #0284c7;">
                            <i class="bi bi-filetype-py" style="font-size: 4rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">Python Programming</h6>
                            <p class="text-muted small mb-4 flex-grow-1">Test your proficiency in Python algorithms, data structures, and object-oriented paradigms.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-light text-dark border"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="text-primary fw-semibold small">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=4'">
                        <div class="exam-img-container" style="background-color: #fef08a; color: #ca8a04;">
                            <i class="bi bi-arrow-repeat" style="font-size: 4rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">Agile ScrumMaster</h6>
                            <p class="text-muted small mb-4 flex-grow-1">Official evaluation covering Agile methodologies, sprint planning, and Scrum ceremonies.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-light text-dark border"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="text-primary fw-semibold small">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=5'">
                        <div class="exam-img-container" style="background-color: #dcfce7; color: #16a34a;">
                            <i class="bi bi-diagram-3-fill" style="font-size: 4rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">ITIL 4 Foundation</h6>
                            <p class="text-muted small mb-4 flex-grow-1">Demonstrate understanding of modern IT service management and organizational value delivery.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-light text-dark border"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="text-primary fw-semibold small">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=6'">
                        <div class="exam-img-container" style="background-color: #fee2e2; color: #dc2626;">
                            <i class="bi bi-shield-lock-fill" style="font-size: 4rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">Cybersecurity Fundamentals</h6>
                            <p class="text-muted small mb-4 flex-grow-1">Assess your knowledge of threat vectors, network defense mechanisms, and access control.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-light text-dark border"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="text-primary fw-semibold small">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=7'">
                        <div class="exam-img-container" style="background-color: #f3e8ff; color: #9333ea;">
                            <i class="bi bi-pc-display" style="font-size: 4rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">CompTIA A+ Certification</h6>
                            <p class="text-muted small mb-4 flex-grow-1">Prove your ability to support IT enterprise systems by validating your skills in hardware, OS, networking, and security.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-light text-dark border"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="text-primary fw-semibold small">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=8'">
                        <div class="exam-img-container" style="background-color: #ffedd5; color: #ea580c;">
                            <i class="bi bi-fingerprint" style="font-size: 4rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">CompTIA Security+</h6>
                            <p class="text-muted small mb-4 flex-grow-1">Validate the baseline skills necessary to improve security readiness and apply current best practices against threats.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-light text-dark border"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="text-primary fw-semibold small">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=9'">
                        <div class="exam-img-container" style="background-color: #cffafe; color: #0891b2;">
                            <i class="bi bi-cpu" style="font-size: 4rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">CompTIA Tech+</h6>
                            <p class="text-muted small mb-4 flex-grow-1">An entry-level certification that validates foundational IT knowledge including networking, security, and cloud-based storage.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-light text-dark border"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="text-primary fw-semibold small">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=10'">
                        <div class="exam-img-container" style="background-color: #fef9c3; color: #eab308;">
                            <i class="bi bi-bar-chart-steps" style="font-size: 4rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">Microsoft Power BI Data Analyst</h6>
                            <p class="text-muted small mb-4 flex-grow-1">Learn to clean, transform, and load data to create robust business intelligence reports and dashboards.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-light text-dark border"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="text-primary fw-semibold small">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=11'">
                        <div class="exam-img-container" style="background-color: #e0e7ff; color: #4f46e5;">
                            <i class="bi bi-cloud-arrow-up-fill" style="font-size: 4rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">Microsoft Azure Fundamentals</h6>
                            <p class="text-muted small mb-4 flex-grow-1">Prove your foundational level knowledge on Azure concepts, core solutions, and network security.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-light text-dark border"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="text-primary fw-semibold small">Start Exam <i class="bi bi-arrow-right"></i></span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 col-xl-4">
                    <div class="exam-card" onclick="window.location.href='ExamIntroServlet?courseId=12'">
                        <div class="exam-img-container" style="background-color: #ede9fe; color: #7c3aed;">
                            <i class="bi bi-database-fill-gear" style="font-size: 4rem;"></i>
                        </div>
                        <div class="p-4 flex-grow-1 d-flex flex-column">
                            <h6 class="fw-bold mb-2">SQL for Data Analysis</h6>
                            <p class="text-muted small mb-4 flex-grow-1">Write efficient queries, perform CRUD operations, and interact with relational databases using SQL.</p>
                            <div class="d-flex justify-content-between align-items-center mt-auto">
                                <span class="badge bg-light text-dark border"><i class="bi bi-ui-checks-grid me-1"></i> Multiple Choice</span>
                                <span class="text-primary fw-semibold small">Start Exam <i class="bi bi-arrow-right"></i></span>
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