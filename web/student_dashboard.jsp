<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal Dashboard</title>
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
            <a class="nav-link-custom text-danger" href="LogoutServlet"><i class="bi bi-box-arrow-left"></i> Sign Out</a>
        </nav>
    </aside>

    <main class="main-content">
        <header class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold m-0">Welcome Back, User!</h4>
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

        <section class="row g-4 mb-4">
            <div class="col-12 col-sm-6 col-lg-4">
                <div class="card metric-card p-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">Active Exams</span>
                            <h3 class="fw-bold m-0 mt-1">3</h3>
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
                            <span class="text-muted small fw-semibold text-uppercase">Completed Tasks</span>
                            <h3 class="fw-bold m-0 mt-1">12</h3>
                        </div>
                        <div class="icon-box" style="background-color: rgba(45, 212, 191, 0.1); color: #2DD4BF;">
                            <i class="bi bi-check-circle fs-4"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-12 col-sm-6 col-lg-4">
                <div class="card metric-card p-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <span class="text-muted small fw-semibold text-uppercase">Overall Average</span>
                            <h3 class="fw-bold m-0 mt-1">94.2%</h3>
                        </div>
                        <div class="icon-box" style="background-color: rgba(251, 191, 36, 0.1); color: #FBBF24;">
                            <i class="bi bi-award fs-4"></i>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="card border-0 shadow-sm rounded-4 p-4">
            <h5 class="fw-bold mb-3">Recent Portal Updates</h5>
            <div class="text-center py-5 text-muted">
                <i class="bi bi-folder2-open fs-1"></i>
                <p class="mt-2 mb-0">No active notices posted inside the workspace engine currently.</p>
            </div>
        </section>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>