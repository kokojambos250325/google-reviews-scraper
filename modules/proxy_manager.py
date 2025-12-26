"""
Smart Proxy Manager with automatic IP rotation.
Based on proxy market recommendation for residential proxies.
"""

import logging
import os
import time
from typing import Optional

log = logging.getLogger("scraper")


class ProxyManager:
    """
    Manages proxy rotation for residential proxies.
    Rotates IP by changing port after N requests to avoid detection.
    """
    
    # Proxy configuration from environment
    PROXY_HOST = os.environ.get('PROXY_HOST')
    PROXY_PORT_START = int(os.environ.get('PROXY_PORT_START', '10000'))
    PROXY_PORT_END = int(os.environ.get('PROXY_PORT_END', '10999'))
    PROXY_USER = os.environ.get('PROXY_USER')
    PROXY_PASS = os.environ.get('PROXY_PASS')
    USE_PROXY = os.environ.get('USE_PROXY', 'false').lower() == 'true'
    
    # Max requests per IP before rotation (10-30 optimal for residential)
    MAX_REQUESTS_PER_IP = int(os.environ.get('MAX_REQUESTS_PER_IP', '15'))
    
    # Delay between requests (in seconds)
    REQUEST_DELAY = float(os.environ.get('PROXY_REQUEST_DELAY', '3.0'))
    
    def __init__(self):
        """Initialize proxy manager"""
        self.current_port = self.PROXY_PORT_START
        self.requests_on_current_ip = 0
        self.last_request_time = 0
        
        if self.USE_PROXY:
            self._validate_config()
            log.info(f"✅ Proxy Manager initialized")
            log.info(f"   Host: {self.PROXY_HOST}")
            log.info(f"   Port range: {self.PROXY_PORT_START}-{self.PROXY_PORT_END}")
            log.info(f"   Max requests per IP: {self.MAX_REQUESTS_PER_IP}")
            log.info(f"   Request delay: {self.REQUEST_DELAY}s")
        else:
            log.info("⚠️ Proxy disabled (USE_PROXY != true)")
    
    def _validate_config(self):
        """Validate proxy configuration"""
        if not self.PROXY_HOST:
            raise ValueError("PROXY_HOST environment variable is required when USE_PROXY=true")
        if not self.PROXY_USER:
            raise ValueError("PROXY_USER environment variable is required when USE_PROXY=true")
        if not self.PROXY_PASS:
            raise ValueError("PROXY_PASS environment variable is required when USE_PROXY=true")
        
        if self.PROXY_PORT_START > self.PROXY_PORT_END:
            raise ValueError(f"PROXY_PORT_START ({self.PROXY_PORT_START}) must be <= PROXY_PORT_END ({self.PROXY_PORT_END})")
    
    def get_proxy_url(self) -> Optional[str]:
        """
        Get current proxy URL with automatic rotation.
        Returns proxy URL in format: http://user:pass@host:port
        
        Returns:
            Optional[str]: Proxy URL or None if proxy is disabled
        """
        if not self.USE_PROXY:
            return None
        
        # Check if we need to rotate IP
        if self.requests_on_current_ip >= self.MAX_REQUESTS_PER_IP:
            self._rotate_ip()
        
        # Increment request counter
        self.requests_on_current_ip += 1
        
        # Build proxy URL
        proxy_url = f"http://{self.PROXY_USER}:{self.PROXY_PASS}@{self.PROXY_HOST}:{self.current_port}"
        
        # Log with masked credentials
        masked_url = f"http://{self.PROXY_USER}:***@{self.PROXY_HOST}:{self.current_port}"
        log.debug(f"🔄 Using proxy: {masked_url} (request {self.requests_on_current_ip}/{self.MAX_REQUESTS_PER_IP})")
        
        return proxy_url
    
    def _rotate_ip(self):
        """Rotate to next IP by changing port"""
        old_port = self.current_port
        
        # Move to next port
        self.current_port += 1
        if self.current_port > self.PROXY_PORT_END:
            self.current_port = self.PROXY_PORT_START
        
        # Reset counter
        self.requests_on_current_ip = 0
        
        log.info(f"🔄 Rotating IP: port {old_port} → {self.current_port}")
    
    def wait_between_requests(self):
        """
        Wait required delay between requests to avoid rate limiting.
        Based on proxy market recommendation: 3 seconds between requests.
        """
        if not self.USE_PROXY:
            return
        
        # Calculate time since last request
        current_time = time.time()
        time_since_last = current_time - self.last_request_time
        
        if time_since_last < self.REQUEST_DELAY:
            wait_time = self.REQUEST_DELAY - time_since_last
            log.debug(f"⏱️ Waiting {wait_time:.1f}s between requests...")
            time.sleep(wait_time)
        
        self.last_request_time = time.time()
    
    def reset(self):
        """Reset proxy manager state (useful for retries)"""
        self.current_port = self.PROXY_PORT_START
        self.requests_on_current_ip = 0
        self.last_request_time = 0
        log.info("🔄 Proxy manager reset to initial state")
    
    def get_stats(self) -> dict:
        """Get current proxy manager statistics"""
        return {
            "enabled": self.USE_PROXY,
            "current_port": self.current_port if self.USE_PROXY else None,
            "requests_on_current_ip": self.requests_on_current_ip if self.USE_PROXY else None,
            "max_requests_per_ip": self.MAX_REQUESTS_PER_IP if self.USE_PROXY else None,
            "proxy_host": self.PROXY_HOST if self.USE_PROXY else None,
        }
