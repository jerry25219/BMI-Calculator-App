let deeplinkUri: string | undefined = undefined;

/**
 * Sanitize URI to ensure it's safe for UTF-8 encoding and proper structure
 */
function sanitizeUri(uri: string): string {
  try {
    if (!uri || uri.length === 0) {
      return '';
    }

    // Remove any leading/trailing whitespace
    let sanitized = uri.trim();
    
    // Remove any non-printable characters that might cause UTF-8 issues
    sanitized = sanitized.replace(/[\0-\x1F\x7F]/g, '');
    
    return sanitized;
  } catch (error) {
    console.error('Error sanitizing URI:', uri, 'error:', error);
    return '';
  }
}

export function setDeeplinkUri(uri: string) {
  const sanitizedUri = sanitizeUri(uri);
  console.log('Set deep link URI:', uri);
  deeplinkUri = sanitizedUri;
}

export function getDeeplinkUri(): string | undefined {
  return deeplinkUri;
}