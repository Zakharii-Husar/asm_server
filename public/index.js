// Get local time and update the DOM
function updateLocalTime() {
    const now = new Date();
    const localTime = now.toLocaleTimeString();
    document.getElementById('local-time').textContent = localTime;
}

// Get host name and port number and update the DOM
function updateHostAndPort() {
    const hostName = window.location.hostname;
    const portNumber = window.location.port || 'N/A'; // Default to 'N/A' if no port is specified
    document.getElementById('host-name').textContent = hostName;
    document.getElementById('port-number').textContent = portNumber;
}

// Initial updates
updateLocalTime();
updateHostAndPort();

// Update local time every second
setInterval(updateLocalTime, 1000);