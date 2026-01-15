// Visitor counter logic
async function updateVisitorCount() {
    const countElement = document.getElementById('visitor-count');
    
    // Only run if visitor counter element exists (on about.html page)
    if (!countElement) {
        return;
    }

    try {
        const API_ENDPOINT = 'https://fubpixvfia.execute-api.us-east-1.amazonaws.com/prod/count';

        const response = await fetch(API_ENDPOINT);
        const data = await response.json();

        countElement.textContent = data.count;
    } catch (error) {
        console.error('Error fetching visitor count:', error);
        countElement.textContent = 'Error loading count';
    }
}

// Mobile menu toggle
function initMobileMenu() {
    const hamburger = document.getElementById('hamburger');
    const navMenu = document.getElementById('nav-menu');
    const navLinks = document.querySelectorAll('.nav-link');

    // Check if elements exist
    if (!hamburger || !navMenu) {
        console.warn('Hamburger menu elements not found');
        return;
    }

    // Toggle menu on hamburger click
    hamburger.addEventListener('click', (e) => {
        e.stopPropagation(); // Prevent event from bubbling to document
        hamburger.classList.toggle('active');
        navMenu.classList.toggle('active');
    });

    // Close menu when clicking a nav link
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            hamburger.classList.remove('active');
            navMenu.classList.remove('active');
        });
    });

    // Close menu when clicking outside (but not on hamburger)
    document.addEventListener('click', (e) => {
        const isClickInsideNav = navMenu.contains(e.target);
        const isClickOnHamburger = hamburger.contains(e.target);
        
        if (!isClickInsideNav && !isClickOnHamburger) {
            hamburger.classList.remove('active');
            navMenu.classList.remove('active');
        }
    });
}

// Dark mode toggle
function initDarkMode() {
    const themeToggle = document.getElementById('theme-toggle');
    
    if (!themeToggle) {
        console.warn('Theme toggle button not found');
        return;
    }
    
    // Check for saved theme preference or default to light
    const currentTheme = localStorage.getItem('theme') || 'light';
    if (currentTheme === 'dark') {
        document.body.classList.add('dark-mode');
    }
    
    // Toggle theme on button click
    themeToggle.addEventListener('click', () => {
        document.body.classList.toggle('dark-mode');
        
        // Save preference to localStorage
        const theme = document.body.classList.contains('dark-mode') ? 'dark' : 'light';
        localStorage.setItem('theme', theme);
        
        // Optional: Add a subtle animation feedback
        themeToggle.style.transform = 'rotate(360deg)';
        setTimeout(() => {
            themeToggle.style.transform = '';
        }, 300);
    });
}

// Scroll animations
function initScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, observerOptions);

    // Observe About Me elements
    const aboutImage = document.querySelector('.about-image-wrapper');
    const aboutText = document.querySelector('.about-text');
    
    if (aboutImage) observer.observe(aboutImage);
    if (aboutText) observer.observe(aboutText);

    // Observe all experience and project items for fade-in effect
    const animatedElements = document.querySelectorAll('.experience-item, .project-item, .education-item');
    animatedElements.forEach(el => {
        el.classList.add('fade-in-up');
        observer.observe(el);
    });
}

// Initialize on page load
window.addEventListener('DOMContentLoaded', () => {
    updateVisitorCount();
    initMobileMenu();
    initScrollAnimations();
    initDarkMode();  // Initialize dark mode
});