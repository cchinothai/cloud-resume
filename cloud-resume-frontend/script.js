// Visitor counter logic
async function updateVisitorCount() {
    const countElement = document.getElementById('visitor-count');

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

    // Toggle menu on hamburger click
    hamburger.addEventListener('click', () => {
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

    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
        if (!hamburger.contains(e.target) && !navMenu.contains(e.target)) {
            hamburger.classList.remove('active');
            navMenu.classList.remove('active');
        }
    });
}

// Initialize on page load
window.addEventListener('DOMContentLoaded', () => {
    updateVisitorCount();
    initMobileMenu();
});