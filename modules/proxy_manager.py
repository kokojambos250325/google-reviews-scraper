"""
Proxy Manager for IP Rotation via Port Changes
Based on proxy market support recommendations for residential proxies
"""
import os
import time
from typing import Optional
from loguru import logger


class ProxyManager:
    """
    Manages proxy rotation by changing port numbers.
    
    For residential proxies, rotating the port (10000-10999) gives a new IP.
    Optimal: 10-30 requests per IP, with 3-second delays between requests.
    """
    
    # Proxy configuration from environment
    PROXY_HOST = os.environ.get('PROXY_HOST')
    PROXY_PORT_START = int(os.environ.get('PROXY_PORT_START', '10000'))
    PROXY_PORT_END = int(os.environ.get('PROXY_PORT_END', '10999'))
    PROXY_USER = os.environ.get('PROXY_USER')
    PROXY_PASS = os.environ.get('PROXY_PASS')
    USE_PROXY = os.environ.get('USE_PROXY', 'false').lower() == 'true'
    
    # Rotation settings
    MAX_REQUESTS_PER_IP = int(os.environ.get('MAX_REQUESTS_PER_IP', '15'))  # 10-30 optimal for residential
    REQUEST_DELAY = float(os.environ.get('PROXY_REQUEST_DELAY', '3.0'))  # seconds between requests
    
    def __init__(self):
        self.current_port = self.PROXY_PORT_START
        self.requests_on_current_ip = 0
        self.last_request_time = 0
        
        if self.USE_PROXY:
            if not all([self.PROXY_HOST, self.PROXY_USER, self.PROXY_PASS]):
                raise ValueError(
                    "Proxy enabled but missing credentials. "
                    "Set PROXY_HOST, PROXY_USER, PROXY_PASS environment variables."
                )
            logger.info(
                f"🔄 Proxy Manager initialized: {self.PROXY_HOST}, "
                f"ports {self.PROXY_PORT_START}-{self.PROXY_PORT_END}, "
                f"max {self.MAX_REQUESTS_PER_IP} requests per IP"
            )
    
    def get_proxy_url(self) -> Optional[str]:
        """
        Get current proxy URL, rotating IP if necessary.
        
        Returns:
            Proxy URL string or None if proxy disabled
        """
        if not self.USE_PROXY:
            return None
        
        # Check if we need to rotate IP
        if self.requests_on_current_ip >= self.MAX_REQUESTS_PER_IP:
            self._rotate_ip()
        
        self.requests_on_current_ip += 1
        
        proxy_url = f"http://{self.PROXY_USER}:{self.PROXY_PASS}@{self.PROXY_HOST}:{self.current_port}"
        
        logger.debug(
            f"📡 Proxy: port {self.current_port}, "
            f"request {self.requests_on_current_ip}/{self.MAX_REQUESTS_PER_IP}"
        )
        
        return proxy_url
    
    def _rotate_ip(self):
        """Rotate to next IP by incrementing port"""
        old_port = self.current_port
        
        self.current_port += 1
        if self.current_port > self.PROXY_PORT_END:
            self.current_port = self.PROXY_PORT_START
        
        self.requests_on_current_ip = 0
        
        logger.info(
            f"🔄 IP rotated: port {old_port} → {self.current_port} "
            f"(max requests reached)"
        )
    
    def wait_between_requests(self):
        """
        Enforce delay between requests to avoid rate limiting.
        Required by proxy provider for stable operation.
        """
        if not self.USE_PROXY:
            return
        
        current_time = time.time()
        time_since_last_request = current_time - self.last_request_time
        
        if time_since_last_request < self.REQUEST_DELAY:
            sleep_time = self.REQUEST_DELAY - time_since_last_request
            logger.debug(f"⏳ Waiting {sleep_time:.1f}s between requests...")
            time.sleep(sleep_time)
        
        self.last_request_time = time.time()
    
    def reset(self):
        """Reset proxy manager to initial state"""
        self.current_port = self.PROXY_PORT_START
        self.requests_on_current_ip = 0
        self.last_request_time = 0
        logger.info("🔄 Proxy manager reset")


# Singleton instance
_proxy_manager_instance = None


def get_proxy_manager() -> ProxyManager:
    """Get singleton ProxyManager instance"""
    global _proxy_manager_instance
    if _proxy_manager_instance is None:
        _proxy_manager_instance = ProxyManager()
    return _proxy_manager_instance
