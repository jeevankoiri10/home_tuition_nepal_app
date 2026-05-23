# My Prompts

1. can you make a docs/plan.md file to make a marketplace app for Home tuition tutors in nepal. Hire teacher and then locate teachers near their area like the bike sharing rides. use the open street map. show the teachers available in their area and book. Phone Number section will be there which we will control. The student can login see the teachers around in their area and then contact tutors directly with their phone number or whatsapp contact.

This should have the login with the google facility, after login provide details. It will asks for the permission to location and automatically takes the location of that teacher using geolocator. The same app is used as the home tutor or as a student. It will act as a bridge between them. ; copy this exact text in docs/my_prompt.md file as 1 number in a bullet and each time i type a prompt this should be saved in this file.

2. It should exactly work like upwork with no payment system

3. They will have the coin system.

4. update the plan. Also use the bloc state management instead of this one.

5. Also the names should be hidden so not searchable outside this platform.

6. Description should not be allowed to enter the number phone details. (Write a note: to the person who is writing description) say them that you account will be blocked if found numbers on description).

Also the surname only 1st letter will be visible and one star * shown so that name not searchable. like upwork.

7. Use supabase instead of the firebase.

8. Also, improve the map view, the main feature is that it is a map view similar to the indrive app where after login student should see the map where nearby tutors can be found. They can reach them directly.

9. Onboarding screen should allow to choose to enter as a student or as a tutor not both.

10. [4 images attached — vacancy-post examples from Gurukul Home Tuitions, Tuition Guru, and Tuition Serve, showing structured fields: Location, Class/Grade, Subject, Time, Salary, Gender, Vacancy No (e.g., GT00276, TG8006, Vac425L), with a WhatsApp number to send CV — example numbers redacted, see prompt #15.] These all things should be available and admin panel will be the mediator between the teacher and the student. I will make an admin panel in nextjs typescript lateron with event driven clean architecture. with authentication and all. Also proper tutorId and studentId should be present, they can be shared via a link directly.

11. Vacancy For Home Tuition Teacher
Kapan
No.of student: 1.
Grade: 7.
Subjects: All.
Location: Kapan, Faika Chowk.
Duration: 7:45 Pm to 8:45 Pm.
Tutor: Male Only.
Salary: Rs 8.5k Per Month.
Apply: Send your updated cv at WhatsApp [REDACTED — template example only, see prompt #15].
Note: Only Nearby location & experienced School teachers are requested to apply, these are the details generally used while searching for a tutors.

12. The name of this app is "Home Tuition Nepal" by KTM academy

13. Search tutors in your locality is the main feature of this app.

14. This will have two languages nepali and english mode.

15. Whatsapp contact for the user is wa.me/9779807590455, remove other whatsapp or details if present. I was sending you the template only.

16. this is the whatsapp to contact the admin of the app.

17. This is changeable via the admin panel later on.

18. make a docs/admin_panel_plan.md file to make a good plan for the admin panel.

19. make a docs/tutor_UI.md file for the tutors related UI and all the details.

20. make a docs/student_UI.md file for the students related UI and all the details and which screens are present.

21. can i use claude design locally ?

22. Always write clean code. Always use reusable components throughout this project. write this in claude.md file.

23. tell me in brief how the mobile interface for the students looks like.

24. to apply to a job 1 coin is needed. There will be 1000 coins initially, controllable via the admin panel.

25. [Image attached — TeachMandu screenshot showing a "Select Student's Level" picker with options: Below Class 9, SEE, +2, A Level, with a "Skip to Home" link and "Register as Teacher" CTA.] but only show the student levels that they can teach to. how will this be handled in the map interface then.

26. [Image attached — TeachMandu tutor profile screen titled "Welcome Pooja Aryal" showing (a) a Subjects Offered table with columns Level / Subject / Price (row example: Below Class 9 / Science / 8000) and (b) an "Are you Available?" grid with three time-of-day rows (Pre 10am, 10–5pm, After 5pm) × seven days of the week (Sun–Sat) as Yes/No checkboxes, with Update Details / Logout buttons.] add this feature as well.

27. [Image attached — TeachMandu "Find Teachers" list screen with a search/filter icon. Each row shows: circular avatar, name (e.g., karunakc, Bidhya tiwari, Shreejana Pandey), a location chip (Kalimati, Chabahil, Lazimpat, Kapan, etc.), a one-line qualification (e.g., "bachelores in social work", "+2 in science", "Bachelors in microbiology", "BSC.CSIT"), a price (Rs. 7,000 / 8,000 / 4,000 / 5,000 / 10,000) and a rating field showing "Not rated". Bottom tabs are "Find Teachers" and "Teachers Login".] consider this image as well.

28. [Image attached — TeachMandu teacher detail screen for "Roshni Khanal" showing: avatar + name + price (Rs. 5,000) + area chip (Koteswor, Kathmandu) + "Not rated ☆" badge + level chip ("+2 Science"), a green BOOK THIS TEACHER button, and sections "ABOUT ME" (bio paragraph about Bachelor's in Social Work and teaching experience), "ABOUT MY SESSIONS" (teaching-methodology paragraph), and "QUALIFICATIONS" (cut off in screenshot).] also the teachers description will look like this one.

29. Also the tutors are allowed to create account as the online, offline or both tutors.

30. First Name / First Name / Last Name / Last Name / Email address / Email address / Phone number / Enter phone number / Password / Password / Confirm password / Confirm password / Role: "I'm a tutor" or "I'm a student" / I accept Terms of Service & Privacy Policy / Register — while account creation, these details should be there as a tutor registration. Same form also applies for student registration ("Create your account").

31. [Pasted text — "Tutors' Code of Conduct: Professionalism, ethics and accountability for Prosikshya tutors", covering Standard ethics & etiquette, Professionalism, Confidentiality, Competence and knowledge, Fairness and Impartiality, Communication, Integrity, Safety and Well-being, Boundaries, Continuous Professional Development, Compliance with Laws and Regulations. Plus a "Become a tutor / How it works for tutors" section.] somewhere list this as well.

32. Identity Verification Approved

33. [Pasted tutor profile-settings screen from Prosikshya — sidebar with: Personal details, My education, My subjects, My availability, Identity verification; draft-mode banner with profile completion %; Personal details form fields: Full Name (first / last), Email, Phone, Gender (Male/Female/Not specified), Your tagline, Meta keywords, Address (Country / Zone / City / Address), Native language, Tutor mode (Online / Offline), Languages I know (huge multi-select), "Write with AI" helper for the bio, A brief introduction textarea (min 300 words), Profile photo uploader, Save & Update button; also a header with wallet balance + withdraw + sign out.] for a tutor these should be present.

34. My education — Education / Experience / Certificates & Awards — but optional as well.

35. [Pasted TeacherOn (teacheron.com) browse page — "All Subjects assignment tutors in Nepal" with nav (Find Tutors / Find Tutor Jobs / Assignment help / Login / Request a tutor), province + subject filters, and ~20 tutor cards each showing: name, profile image, multiple subject tags (e.g., "All 5th class subjects", "All 6th grade subjects", "Nursery to 6th grade, all subjects"), a long bio excerpt, and a bottom metadata row with location (e.g., Bagmati Province), price (रू6,000–10,000/month, रू400/hour, रू850–1,500/day, etc.), two experience metrics (offline teaching years + online teaching years), and distance (km). Footer with lots of info pages: Locations, Resources (Learning mind, About us, Stay safe, Blog, Refer & earn coins, FAQs, Coins & Pricing, How it works - Students, Pay teachers), For teachers (Get paid, Premium membership, Online teaching guide, How it works - Teachers, How to get jobs, Applying to jobs, Teacher Rankings), Help and Feedback (Testimonials, Contact us, Refund Policy, Privacy Policy, Terms, Games).] Can you just take idea from these teacheron. it is a good one.

36. [Pasted TeacherOn assignment-help job listing — "Online General Science assignment help tutor needed in Mamada", Contact Ayaan, General Science, location Mamada, Gujrat, Pakistan, Rs 3,000 Fixed (with USD conversion shown), Posted: 3 mins ago, Level: Grade 7, Due Date: 22-05-2026, Requires: Part Time, Posted by: Ayaan (Student), WhatsApp verified +92-****, Gender Preference: None, Available online, Not available for home tutoring, Can not travel, Can communicate in: English, summary "Looking for a job help in assignment".]

37. [Pasted TeacherOn homepage — hero "Find online teachers and home tutors for free", search bar with Subject/Skill + Location, segmented selectors (Teachers / Online Teachers / Home Teachers / Assignment Help) and (Teaching Jobs / Online Teaching / Home Teaching / Assignment Jobs); quality stat "Only 55.1% of teachers that apply make through our application process"; stats grid 18,000+ Subjects · 3,500+ Skills · 1,000+ Languages; about copy ("free website, trusted globally, helps with tutoring/coaching/assignments/academic projects/dissertations"); "200,000+ Active Teachers From 178 Countries"; long horizontal list of top subjects (Academic Writing through Zoology); footer with the standard info pages.] This is the homepage.

38. [Eight screenshots attached from a competitor TeacherOn-style mobile app — (19) Notifications screen with All/Unread/Read tabs and "New job posted" cards listing online/home tutor jobs by location; (20) "Request a Tutor" screen with Details textarea + orange warning "Please don't share any contact details (phone, email, website etc) here", Location card, Phone Number card, Subjects chips (Hindi, Maths), Your Level card; (21) "Coin Wallet" with gradient hero card showing 392 coins, Buy Coins button, Transaction History table with Date / Details / Coins columns including premium-subscription renewals and "For showing contact details to student +1-XXXXXX" rows; (22) "Create Account" with Student/Parents dropdown, Full Name, Email, Password (eye toggle), accept-T&C checkbox, gradient Register button; (23) Chat screen with Teacher2 Test2 header, green message bubbles, double-tick read receipts, "Type a message..." input with gradient send button; (24) "My Posts" with gradient Post Requirement button and post cards each showing title, description excerpt, price (RM5,000/month), location, Closed badge, View Messages / Repost actions; (25) Settings with Appearance (Theme Mode), Account (Profile Settings), Danger Zone (Delete Account, Logout), About (App Version 2.0.9+1); (26) Post Detail with red "This requirement is closed" alert, title, View Messages / Repost buttons, EnCase chip, detail card with icons for Location, Posted date, Requires (Part Time), Posted by, Verified phone, Gender Preference, online/home/travel flags, and a Description section.] make exactly like this. Local notification automatic as soon as the job is posted.

39. But I want the map view if this is feasible to implement, make in the plan.

40. Don't mirror but have an idea that what is needed and make a better one.

41. Make a comprehensive_phasewise_plan.md file in docs and implement the first phase.

42. implement phase 2

43. Implement phase 3

44. continue [interpreted as: implement Phase 4 — Map view + locality search, the headline feature]

45. yes [interpreted as: continue to Phase 5 — Coin system & wallet]

46. continue to next phase [interpreted as: implement Phase 6 — Student request flows]

47. code . [opens the project in VS Code]

48. continue [interpreted as: implement Phase 7 — Vacancies + admin matching (mobile side)]

49. /loop 15 min Continue [cron `*/15 * * * *`, prompt "Continue" — fires every 15 minutes for 7 days (or until session ends), each firing implements the next phase. First firing = Phase 8 — Notifications.]

50. Continue [Phase 9 — In-app chat: chat_threads/chat_messages with RLS, open_or_get_thread + send_chat_message RPCs (server-side phone-ban + gate check), ChatBloc, ChatPage with double-tick reads, FakeChatRepository with auto-echo; "Open chat" wired into the post-unlock sheet.]

51. Continue [Phase 10 — Reviews, ratings, boosts: reviews table + submit_review RPC (gate-checked, server-side phone-ban), recompute_tutor_rating + ranking_score formula, boost_tutor_featured + promote_job RPCs, SubmitReviewSheet with star input, "Leave a review" CTA in the post-unlock sheet, "Boost listing" tile on tutor home.]

52. Continue [Phase 11 — Coin top-ups: coin_packs + coin_top_ups schema with start_top_up / finalize_top_up (idempotent webhook-verified credit via _ledger_apply) / cancel_top_up RPCs, CoinPack + TopUp domain, FakeTopUpsRepository with debugSimulateSuccess, ProviderPickerSheet (eSewa / Khalti / IME Pay), CoinPacksPage; wallet "Buy Coins" now routes to /wallet/buy; SDK integration documented in docs/payment_setup.md.]

53. Continue [Phase 12 — Admin panel hardening (backend contract): profiles.suspended_until/banned_at + _is_blocked() guard wired into unlock_contact / tutor_apply_to_vacancy / send_chat_message, append-only audit_events with _audit() helper, moderation_log + user_report_content RPC, verifications history table + admin_review_verification (auto-credits +50 coins on approve), admin_suspend/ban/unban_user, admin_set_setting (with old/new in audit), admin_resolve_moderation, AccountBlockedBanner widget, docs/admin_panel_backend_contract.md handover for the Next.js codebase.]

54. Continue [Phase 13 — Public marketing site (backend + deep links): profiles.public_code (T-XXXXXX) and jobs.public_code (J-XXXXXX) via _generate_short_code triggers, anon-readable public_tutors_directory view + public_get_tutor / public_search_tutors / public_get_vacancy / public_homepage_stats RPCs (mask-only, no PII), Android App Links intent-filter for htn.app/{t,s,v,j}/* with autoVerify, docs/public_site_backend_contract.md handover (URL scheme, Digital Asset Links template, iOS Universal Links template, SEO/privacy invariants).]

55. Continue [Phase 14 — Hardening + a11y + i18n QA: sentry_flutter wired with env-gated init (Env.hasSentry), runZonedGuarded + FlutterError.onError + PlatformDispatcher.onError forward to Sentry, AppBlocObserver forwards bloc errors with the runtime-type as hint, PII-free defaults (no screenshots/PII/view-hierarchy), a11y tooltips on icon-only sign-out buttons, docs/hardening_checklist.md consolidating security/a11y/i18n pre-beta gates.]
