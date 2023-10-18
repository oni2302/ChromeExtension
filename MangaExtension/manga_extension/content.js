function smoothScrollBy(distance, duration) {
    const startingY = window.scrollY;
    const targetY = startingY + distance;
    let start;
  
    // Animation function
    function step(timestamp) {
      if (!start) start = timestamp;
      const time = timestamp - start;
      const percent = Math.min(time / duration, 1);
      window.scrollTo(0, startingY + (distance * percent));
      if (time < duration) {
        window.requestAnimationFrame(step);
      }
    }
  
    // Start the animation
    window.requestAnimationFrame(step);
  } 