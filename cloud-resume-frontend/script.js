/*
    - Retrieve response endpoint from API Gateway (after backend has updated)
    - Update visibility count shown in frontend
    - Call update function on every page load 
*/
async function updateVisitorCount() {
    const countElement = document.getElementById('visitor-count')

    try {
        // Replace with you actual API endpoint
        const API_ENDPOINT = 'https://fubpixvfia.execute-api.us-east-1.amazonaws.com/prod/count';

        const response = await fetch(API_ENDPOINT);
        const data = await response.json();

        //update countElement
        console.log('data.count : ', data.count)
        countElement.textContent = data.count
    } catch (error) {
        console.error('Error fetching visitor count:', error);
        countElement.textContent = 'Error loading count';
    }

}

//Get the visitor count when page loads
window.addEventListener('DOMContentLoaded', updateVisitorCount);