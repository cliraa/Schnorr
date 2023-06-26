import hashlib
import sys
import random

# secp256k1 domain parameters
Pcurve = 2**256 - 2**32 - 2**9 - 2**8 - 2**7 - 2**6 - 2**4 -1 # The proven prime
Acurve = 0 # These two defines the elliptic curve. y^2 = x^3 + Acurve * x + Bcurve
Bcurve = 7
Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
GPoint = (int(Gx),int(Gy)) # This is our generator point.
N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 # Number of points in the field

msg = "Hello, World!"

if (len(sys.argv)>1):
  msg=str(sys.argv[1])

print("Message: ",msg)
msg=msg.encode()

# Replace with any private key

privKey_alice = random.randrange(2 ** 252, N)
privKey_bob = random.randrange(2 ** 252, N)

def modinv(a,n=Pcurve): #Extended Euclidean Algorithm/'division' in elliptic curves
    lm, hm = 1,0
    low, high = a%n,n
    while low > 1:
        ratio = high//low
        nm, new = hm-lm*ratio, high-low*ratio
        lm, low, hm, high = nm, new, lm, low
    return lm % n

def ECadd(a,b): # EC Addition
    LamAdd = ((b[1]-a[1]) * modinv(b[0]-a[0],Pcurve)) % Pcurve
    x = (LamAdd*LamAdd-a[0]-b[0]) % Pcurve
    y = (LamAdd*(a[0]-x)-a[1]) % Pcurve
    return (x,y)

def ECdouble(a): # EC Doubling
    Lam = ((3*a[0]*a[0]+Acurve) * modinv((2*a[1]),Pcurve)) % Pcurve
    x = (Lam*Lam-2*a[0]) % Pcurve
    y = (Lam*(a[0]-x)-a[1]) % Pcurve
    return (x,y)

def EccMultiply(GenPoint,ScalarHex): # Doubling & Addition
    if ScalarHex == 0 or ScalarHex >= N: raise Exception("Invalid Scalar/Private Key")
    ScalarBin = str(bin(ScalarHex))[2:]
    Q=GenPoint
    for i in range (1, len(ScalarBin)):
        Q=ECdouble(Q)
        if ScalarBin[i] == "1":
            Q=ECadd(Q,GenPoint)
    return (Q)

PublicKey_alice = EccMultiply(GPoint, privKey_alice)
PublicKey_bob = EccMultiply(GPoint, privKey_bob)

XPublicKey_alice = PublicKey_alice[0]
YPublicKey_alice = PublicKey_alice[1]

XPublicKey_bob = PublicKey_bob[0]
YPublicKey_bob = PublicKey_bob[1]

print("Alice Private Key:", privKey_alice)
print("Bob Private Key:", privKey_bob)

print("Public Key Alice:")
print("XCoor is: " + str(XPublicKey_alice))
print("YCoor is: " + str(YPublicKey_alice))

print("Public Key Bob:")
print("XCoor is: " + str(XPublicKey_bob))
print("YCoor is: " + str(YPublicKey_bob))

# Random nonce:

r_alice = random.randrange(2 ** 252, N)
r_bob = random.randrange(2 ** 252, N)

print("r_alice:", r_alice)
print("r_bob:", r_bob)

# Public nonce:

R_a = EccMultiply(GPoint, r_alice)
R_b = EccMultiply(GPoint, r_bob)

# Aggregated public nonce:

R = ECadd(R_a,R_b)

# Hash of the public key set:

P_a_bytes = (PublicKey_alice[0]).to_bytes(32,'big')
P_b_bytes = (PublicKey_bob[0]).to_bytes(32,'big')

hasher=hashlib.sha256()
hasher.update(P_a_bytes + P_b_bytes)
h = hasher.digest()
H = int.from_bytes(h,'big')
l = H
print("l:", l)

# Weight factor:

l_bytes = (l).to_bytes(32,'big')

hasher_2 = hashlib.sha256()
hasher_2.update(l_bytes + P_a_bytes)
h_2 = hasher_2.digest()
H_2 = int.from_bytes(h_2,'big')
w_a = H_2
print("w_a:", w_a)

hasher_3 = hashlib.sha256()
hasher_3.update(l_bytes + P_b_bytes)
h_3 = hasher_3.digest()
H_3 = int.from_bytes(h_3,'big')
w_b = H_3
print("w_b:", w_b)

# Aggregated public key:

X_1 = EccMultiply(PublicKey_alice, w_a)
X_2 = EccMultiply(PublicKey_bob, w_b)

X = ECadd(X_1, X_2)

# Challenge e:

R_bytes = (R[0]).to_bytes(32,'big')
X_bytes = (X[0]).to_bytes(32,'big')

hasher_4 = hashlib.sha256()
hasher_4.update(R_bytes + X_bytes + msg)
h_4 = hasher_4.digest()
H_4 = int.from_bytes(h_4,'big')
e = H_4
print("e:", e)

# Signature:

s_a = (r_alice + (privKey_alice * w_a * e)) % N
s_b = (r_bob + (privKey_bob * w_b * e)) % N

# Aggregated signature:

s = (s_a + s_b) % N

# Verification:

sG = EccMultiply(GPoint,s)
v1 = sG

ver = EccMultiply(X,e)
v2 = ECadd(R, ver)

print("v1:", v1)
print("v2:", v2)

if (v1==v2):
  print ("\nVerified!")
