<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Examination Interface</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        :root {
            /* NexaFlow Premium Deep Matte Testing Canvas */
            --bg-gradient: radial-gradient(circle at 50% 0%, #130a2a 0%, #04020a 100%);
            --header-bg: #090612;
            --card-bg: rgba(20, 15, 34, 0.7);
            
            /* UI States & Accents */
            --accent-purple: #8B5CF6;
            --accent-teal: #2DD4BF;
            --border-glass: rgba(255, 255, 255, 0.06);
            --border-glass-top: rgba(255, 255, 255, 0.15);

            /* High Contrast Accessible Text */
            --text-heading: #ffffff;
            --text-body: #f1f5f9;
            --text-muted: #94a3b8;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-gradient);
            background-attachment: fixed;
            color: var(--text-body);
            min-height: 100vh;
            padding-top: 105px;
            margin: 0;
            position: relative;
            user-select: none; /* Anti-cheat text protection mapping */
            -webkit-user-select: none;
        }

        /* Subtle Noise Overlay texture layer */
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

        .container {
            position: relative;
            z-index: 2;
        }
        
        /* Fixed Isolation Header (Zero distraction mapping strategy) */
        .exam-header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 80px;
            background-color: var(--header-bg);
            border-bottom: 1px solid var(--border-glass);
            z-index: 1030;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 2.5rem;
        }

        h5, h6 {
            font-family: 'Plus Jakarta Sans', sans-serif;
            letter-spacing: -0.01em;
            color: var(--text-heading);
        }

        /* Question Cards Architecture */
        .question-card {
            background: var(--card-bg);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid var(--border-glass);
            border-top: 1px solid var(--border-glass-top);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
            padding: 2.5rem;
            margin-bottom: 1.5rem;
            min-height: 380px;
        }

        /* High-Visibility Custom Interactive Choice Rows */
        .option-container {
            display: flex;
            align-items: center;
            position: relative;
            padding: 1.2rem 1.2rem 1.2rem 3.8rem;
            margin-bottom: 0.95rem;
            cursor: pointer;
            background-color: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--border-glass);
            border-radius: 14px;
            font-weight: 500;
            color: var(--text-body);
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .option-container:hover {
            background-color: rgba(255, 255, 255, 0.05);
            border-color: rgba(139, 92, 246, 0.4);
            transform: scale(1.005);
        }

        .option-container input {
            position: absolute;
            opacity: 0;
            cursor: pointer;
        }

        .checkmark {
            position: absolute;
            top: 50%;
            left: 1.5rem;
            transform: translateY(-50%);
            height: 22px;
            width: 22px;
            background-color: rgba(0, 0, 0, 0.4);
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            transition: all 0.2s ease;
        }

        /* Dynamic Active Selection Overrides (Success Teal & Soft Purple Fusion) */
        .option-container.active-selected {
            border-color: var(--accent-teal);
            background-color: rgba(45, 212, 191, 0.08);
            color: #ffffff;
            font-weight: 600;
            box-shadow: 0 0 15px rgba(45, 212, 191, 0.1);
        }

        .option-container.active-selected .checkmark {
            border-color: var(--accent-teal);
            background-color: var(--accent-teal);
        }

        .option-container.active-selected .checkmark::after {
            content: "";
            position: absolute;
            top: 5px;
            left: 5px;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #000000;
        }

        /* Sidebar Navigation Component Grid Boxes */
        .sidebar-nav-card {
            background: var(--card-bg);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid var(--border-glass);
            border-top: 1px solid var(--border-glass-top);
        }

        .nav-grid-box {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            border: 1px solid var(--border-glass);
            background-color: rgba(0, 0, 0, 0.3);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 0.95rem;
            color: var(--text-muted);
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
        }

        .nav-grid-box:hover {
            border-color: var(--accent-purple);
            color: #ffffff;
            background-color: rgba(139, 92, 246, 0.2);
        }

        .nav-grid-box.current {
            border-color: var(--accent-purple);
            box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.3);
            color: #ffffff;
            background-color: rgba(139, 92, 246, 0.25);
        }

        .nav-grid-box.answered {
            background-color: rgba(139, 92, 246, 0.4);
            border-color: var(--accent-purple);
            color: #ffffff;
        }
        
        .nav-grid-box.answered.current {
            box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.5);
            background-color: var(--accent-purple);
        }

        /* Utility Interface Core Actions Elements buttons mapping */
        .btn-nav-control {
            border: 1px solid var(--border-glass);
            background-color: rgba(255, 255, 255, 0.02);
            color: var(--text-body);
            font-weight: 600;
            transition: all 0.2s ease;
        }
        .btn-nav-control:hover:not(:disabled) {
            background-color: rgba(255, 255, 255, 0.08);
            color: #ffffff;
            border-color: var(--text-muted);
        }

        .badge-midterm {
            background-color: rgba(239, 68, 68, 0.15) !important;
            color: #fca5a5 !important;
            border: 1px solid rgba(239, 68, 68, 0.3);
        }
    </style>
</head>
<body>

    <header class="exam-header shadow-sm">
        <div class="d-flex align-items-center">
            <span class="badge badge-midterm fw-bold me-3 px-3 py-2 text-uppercase">Midterm Exam</span>
            <h5 class="fw-bold m-0 text-white">ICS2609: Advanced Database Systems</h5>
        </div>
        <div class="d-flex align-items-center bg-black border px-3 py-2 rounded-3" style="border-color: var(--border-glass) !important;">
            <i class="bi bi-clock-fill text-warning me-2"></i>
            <span class="fw-bold text-white" id="timerDisplay" style="font-variant-numeric: tabular-nums;">01:30:00</span>
        </div>
    </header>

    <div class="container main-container">
        <div class="row g-4">
            
            <main class="col-12 col-lg-8">
                <div class="card question-card">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <span style="color: var(--text-muted);" class="small fw-bold text-uppercase" id="questionProgressText">Question 1 of 4</span>
                        <span class="badge bg-dark text-white border" id="questionPoints" style="border-color: var(--border-glass) !important;">Points: 2.0</span>
                    </div>
                    
                    <h5 class="fw-bold text-white mb-4 lh-base" id="questionTitleText">Loading Question Prompt...</h5>
                    
                    <div id="choicesBlockContainer"></div>
                </div>

                <div class="d-flex justify-content-between align-items-center mt-3 mb-5">
                    <button type="button" class="btn btn-nav-control px-4 py-2 rounded-3" id="prevBtn" onclick="navigateQuestion(-1)">
                        <i class="bi bi-arrow-left me-2"></i> Previous
                    </button>
                    <button type="button" class="btn text-white px-4 py-2 rounded-3 fw-semibold" id="nextBtn" style="background-color: var(--accent-purple); box-shadow: 0 4px 12px rgba(139, 92, 246, 0.2);" onclick="navigateQuestion(1)">
                        Next Question <i class="bi bi-arrow-right ms-2"></i>
                    </button>
                </div>
            </main>

            <aside class="col-12 col-lg-4">
                <div class="card sidebar-nav-card shadow-sm rounded-4 p-4 sticky-top" style="top: 110px; z-index:10;">
                    <h6 class="fw-bold text-white mb-3 fs-6">Examination Overview</h6>
                    
                    <div class="d-flex flex-wrap gap-2 mb-4" id="navigationGridMatrix"></div>
                    
                    <hr class="opacity-20 my-3" style="color: var(--text-muted);">
                    
                    <form id="finalExamSubmissionForm" action="SubmitExamServlet" method="POST">
                        <input type="hidden" name="serializedAnswers" id="serializedAnswersInput">
                        <input type="hidden" name="timeElapsed" id="timeElapsedInput">
                        
                        <button type="button" class="btn btn-danger w-100 py-2.5 rounded-3 fw-bold shadow-sm" style="background-color: #dc2626; border-color: #dc2626;" onclick="triggerExamSubmissionAlert()">
                            <i class="bi bi-send-fill me-2"></i> Submit Examination Paper
                        </button>
                    </form>
                </div>
            </aside>

        </div>
    </div>

    <script>
        // 1. Array Matrix containing Question Objects (Stephen can expand this easily)
        const examQuestions = [
            {
                id: 1,
                points: "2.0",
                text: "Which of the following ACID properties ensures that a concurrent database transaction execution sequence leaves the system database in a valid structural state?",
                options: { A: "Atomicity", B: "Consistency", C: "Isolation", D: "Durability" }
            },
            {
                id: 2,
                points: "2.0",
                text: "What isolation level prevents dirty reads but allows non-repeatable reads to occur within active execution instances?",
                options: { A: "Read Uncommitted", B: "Read Committed", C: "Repeatable Read", D: "Serializable" }
            },
            {
                id: 3,
                points: "2.0",
                text: "In a PostgreSQL environment, what structural protocol architecture design is primarily utilized to handle write concurrency conflicts cleanly without locks?",
                options: { A: "Two-Phase Locking (2PL)", B: "Write-Ahead Logging (WAL)", C: "Multi-Version Concurrency Control (MVCC)", D: "Query Execution Optimization" }
            },
            {
                id: 4,
                points: "4.0",
                text: "Which storage engine framework serves as the native local user table component environment when deploying Apache Derby embedded client configurations?",
                options: { A: "InnoDB Engine Cluster", B: "Derby Core Falcon Storage Engine", C: "Pluggable Disk Database Engine Component", D: "SQLite VFS Mapping Layer" }
            }
        ];

        // 2. Local State Variables Keep Track of User Progress Tracking Matrix 
        let currentQuestionIndex = 0;
        let selectedAnswersLog = {}; // Stores key-value tracking properties (e.g., {1: 'B', 2: 'A'})
        let totalExamTimeSeconds = 90 * 60; // 90 Minutes Total Countdown Duration Assignment

        // 3. Initialize Layout Elements Once Content View Model Is Mount Confirmed
        window.addEventListener('DOMContentLoaded', () => {
            renderSidebarNavigationGrid();
            displayActiveQuestionCard();
            startCountdownTimer();
        });

        // 4. Generate the Sidebar Tracking Box Elements Dynamically
        function renderSidebarNavigationGrid() {
            const gridContainer = document.getElementById('navigationGridMatrix');
            gridContainer.innerHTML = '';
            
            examQuestions.forEach((question, index) => {
                const box = document.createElement('a');
                box.className = 'nav-grid-box';
                box.id = `nav-box-${index}`;
                box.innerText = question.id;
                
                // Add event trigger logic allowing quick jumps by clicking numbers
                box.onclick = () => jumpToQuestion(index);
                gridContainer.appendChild(box);
            });
            updateSidebarHighlightStates();
        }

        // 5. Update Question Fields and Input Nodes Inside Left Panel Card Section
        function displayActiveQuestionCard() {
            const currentQuestion = examQuestions[currentQuestionIndex];
            
            // Map text updates safely 
            document.getElementById('questionProgressText').innerText = `Question ${currentQuestionIndex + 1} of ${examQuestions.length}`;
            document.getElementById('questionPoints').innerText = `Points: ${currentQuestion.points}`;
            document.getElementById('questionTitleText').innerText = currentQuestion.text;
            
            // Build the option radio choice tree components cleanly
            const choicesContainer = document.getElementById('choicesBlockContainer');
            choicesContainer.innerHTML = '';
            
            Object.entries(currentQuestion.options).forEach(([key, val]) => {
                const label = document.createElement('label');
                label.className = 'option-container';
                
                const isChecked = selectedAnswersLog[currentQuestion.id] === key;
                if (isChecked) {
                    label.classList.add('active-selected');
                }
                
                label.innerHTML = `
                    <input type="radio" name="currentQuestionChoice" value="${key}" ${isChecked ? 'checked' : ''} onchange="logUserChoiceSelection('${currentQuestion.id}', '${key}')">
                    <span class="checkmark"></span>
                    <strong>${key}.</strong> &nbsp;${val}
                `;
                
                choicesContainer.appendChild(label);
            });
            
            // Sync active state indicators on interface action elements
            document.getElementById('prevBtn').disabled = (currentQuestionIndex === 0);
            if (currentQuestionIndex === examQuestions.length - 1) {
                document.getElementById('nextBtn').innerHTML = `Review Summary <i class="bi bi-journal-check ms-2"></i>`;
            } else {
                document.getElementById('nextBtn').innerHTML = `Next Question <i class="bi bi-arrow-right ms-2"></i>`;
            }
            
            updateSidebarHighlightStates();
        }

        // 6. Monitor and Log Selection Matrix Changes Locally
        function logUserChoiceSelection(questionId, selectedChoiceLetter) {
            selectedAnswersLog[questionId] = selectedChoiceLetter;
            
            // Visual accent feedback styling trigger logic
            const containers = document.querySelectorAll('.option-container');
            containers.forEach(item => item.classList.remove('active-selected'));
            
            const checkedInput = document.querySelector('input[name="currentQuestionChoice"]:checked');
            if (checkedInput) {
                checkedInput.parentElement.classList.add('active-selected');
            }
            
            updateSidebarHighlightStates();
        }

        // 7. Synchronize Color Accents on Right-Side Grid Layout Component Box Modules
        function updateSidebarHighlightStates() {
            examQuestions.forEach((question, index) => {
                const box = document.getElementById(`nav-box-${index}`);
                if (!box) return;
                
                box.className = 'nav-grid-box'; // reset class template values
                
                if (selectedAnswersLog[question.id]) {
                    box.classList.add('answered');
                }
                if (index === currentQuestionIndex) {
                    box.classList.add('current');
                }
            });
        }

        // 8. Control Prev/Next Button Iteration Logic Flows
        function navigateQuestion(directionOffset) {
            const targetIndex = currentQuestionIndex + directionOffset;
            if (targetIndex >= 0 && targetIndex < examQuestions.length) {
                currentQuestionIndex = targetIndex;
                displayActiveQuestionCard();
            }
        }

        function jumpToQuestion(targetIndex) {
            currentQuestionIndex = targetIndex;
            displayActiveQuestionCard();
        }

        // 9. Process Countdown Expiration Variables and Clock String Formatting 
        function startCountdownTimer() {
            const display = document.getElementById('timerDisplay');
            
            const internalTimerInterval = setInterval(() => {
                let hours = Math.floor(totalExamTimeSeconds / 3600);
                let minutes = Math.floor((totalExamTimeSeconds % 3600) / 60);
                let seconds = totalExamTimeSeconds % 60;
                
                hours = hours < 10 ? '0' + hours : hours;
                minutes = minutes < 10 ? '0' + minutes : minutes;
                seconds = seconds < 10 ? '0' + seconds : seconds;
                
                display.innerText = `${hours}:${minutes}:${seconds}`;
                
                if (--totalExamTimeSeconds < 0) {
                    clearInterval(internalTimerInterval);
                    display.innerText = "00:00:00";
                    alert("Time has officially expired! Your exam will save automatically.");
                    triggerExamSubmissionAlert();
                }
            }, 1000);
        }

        // 10. Package Log Values and Fire to Servlet Controller Configuration
        function triggerExamSubmissionAlert() {
            const totalAnswered = Object.keys(selectedAnswersLog).length;
            const confirmationResponse = confirm(`You have answered ${totalAnswered} out of ${examQuestions.length} questions. Are you completely sure you want to lock in your answers and submit your exam layout paper?`);
            
            if (confirmationResponse) {
                // Calculate exact elapsed duration string (90 minutes minus remaining time)
                const totalDurationSeconds = 90 * 60;
                const elapsedSeconds = totalDurationSeconds - totalExamTimeSeconds;
                const elapsedMinutes = Math.floor(elapsedSeconds / 60);
                const remainingSeconds = elapsedSeconds % 60;
                const timeElapsedString = `${elapsedMinutes}m ${remainingSeconds}s`;

                // Stringify choices matrix array log values and push to backend parameter layer
                document.getElementById('serializedAnswersInput').value = JSON.stringify(selectedAnswersLog);
                document.getElementById('timeElapsedInput').value = timeElapsedString;
                
                document.getElementById('finalExamSubmissionForm').submit();
            }
        }
    </script>
</body>
</html>