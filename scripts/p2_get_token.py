"""Part 2, Step 4: get an access token with a certificate (client credentials flow).

Reads settings from environment variables, signs a client assertion with the
private key in ~/p2-certs/client.key, and asks Entra for a token for the
gateway API. Saves the raw token to ~/p2-certs/token.txt (owner-only) and
prints a REDACTED view of its claims that is safe to screenshot.

Never prints the token itself.
"""

import base64
import json
import os
import stat
import sys
import time
from pathlib import Path

import msal

CERT_DIR = Path.home() / "p2-certs"


def need(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        sys.exit(f"Missing environment variable: {name}")
    return value


def short(value) -> str:
    """Cut IDs to the first 4 characters for screenshots."""
    text = str(value)
    return text[:4] + "…" if len(text) > 4 else text


def decode_claims(token: str) -> dict:
    """Decode the JWT payload WITHOUT verifying it (inspection only)."""
    payload = token.split(".")[1]
    payload += "=" * (-len(payload) % 4)
    return json.loads(base64.urlsafe_b64decode(payload))


def main() -> None:
    tenant_id = need("TENANT_ID")
    client_id = need("CLIENT_ID")
    api_uri = need("API_APP_ID_URI")      # e.g. api://<gateway-api-client-id>
    thumbprint = need("CERT_THUMBPRINT")  # SHA-1, no colons

    private_key = (CERT_DIR / "client.key").read_text()

    app = msal.ConfidentialClientApplication(
        client_id,
        authority=f"https://login.microsoftonline.com/{tenant_id}",
        client_credential={"private_key": private_key, "thumbprint": thumbprint},
    )

    result = app.acquire_token_for_client(scopes=[f"{api_uri}/.default"])

    if "access_token" not in result:
        print("Token request FAILED")
        print("error:", result.get("error"))
        print("description:", result.get("error_description", "")[:300])
        sys.exit(1)

    token = result["access_token"]
    token_path = CERT_DIR / "token.txt"
    token_path.write_text(token)
    token_path.chmod(stat.S_IRUSR | stat.S_IWUSR)

    claims = decode_claims(token)
    acr = claims.get("appidacr", claims.get("azpacr"))
    acr_meaning = {"0": "public client", "1": "client secret", "2": "certificate"}.get(
        str(acr), "unknown"
    )

    print("Token acquired (raw token saved to ~/p2-certs/token.txt, not shown)")
    print()
    print("Redacted claims (safe to screenshot):")
    print(f"  ver      : {claims.get('ver')}")
    aud = str(claims.get("aud", ""))
    if aud.startswith("api://"):
        print(f"  aud      : api://{short(aud[len('api://'):])}  (App ID URI form)")
    else:
        print(f"  aud      : {short(aud)}  (client ID form)")
    print(f"  iss      : {'https://sts.windows.net/' if 'sts.windows.net' in claims.get('iss', '') else 'https://login.microsoftonline.com/'}{short(claims.get('tid'))}/…")
    print(f"  appid    : {short(claims.get('appid', claims.get('azp')))}")
    print(f"  roles    : {claims.get('roles')}")
    print(f"  auth     : appidacr/azpacr = {acr} ({acr_meaning})")
    print(f"  expires  : in {int(claims.get('exp', 0) - time.time()) // 60} minutes")


if __name__ == "__main__":
    main()
