import React, { useState, useEffect } from 'react';

function App() {
  const [stats, setStats] = useState({});

  useEffect(() => {
    const fetchStats = async () => {
      const response = await fetch('/api/stats');
      const data = await response.json();
      setStats(data);
    };

    fetchStats();
    const interval = setInterval(fetchStats, 5000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div>
      <h1>Statystyki odwiedzin</h1>
      <ul>
        {Object.entries(stats).map(([url, count]) => (
          <li key={url}>
            {url}: {count} odwiedzin
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;