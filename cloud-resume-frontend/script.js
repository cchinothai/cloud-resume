async function updateVisitorCount() {
    const countElement = document.getElementById('visitor-count')

    try {
        // Replace with you actual API endpoint
        const API_ENDPOINT = 'https://your-api-gateway-url.com/prod/count';

        const response = await fetch(API_ENDPOINT);
        const data = response.json();

    //update countElement
    countElement.textContent = data.count
    } catch (error) {
        console.error('Error fetching visitor count:', error);
        countElement.textContent = 'Error loading count';
    }

}

//Get the visitor count when page loads
window.addEventListener('DOMContentLoaded', updateVisitorCount);