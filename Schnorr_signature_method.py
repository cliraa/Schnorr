import hashlib
import sys

# secp256k1 domain parameters
Pcurve = 2**256 - 2**32 - 2**9 - 2**8 - 2**7 - 2**6 - 2**4 -1 # The proven prime
Acurve = 0 # These two defines the elliptic curve. y^2 = x^3 + Acurve * x + Bcurve
Bcurve = 7
Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
GPoint = (int(Gx),int(Gy)) # This is our generator point.
N=0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 # Number of points in the field

msg = "Hello, World!"

if (len(sys.argv)>1):
  msg=str(sys.argv[1])

print("Message: ",msg)
msg=msg.encode()

# Replace with any private key
privKey_bob = 77664663271170673620859955297191590031376319879614890096024130175852238738811
privKey_alice = 89652975980192045565381556847798492396888680198332589948144044069692575244768

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

PublicKey_bob = EccMultiply(GPoint,privKey_bob)
PublicKey_alice = EccMultiply(GPoint,privKey_alice)

XPublicKey_bob = PublicKey_bob[0]
YPublicKey_bob = PublicKey_bob[1]

XPublicKey_alice = PublicKey_alice[0]
YPublicKey_alice = PublicKey_alice[1]

print("Public Key Bob:")
print("XCoor is: " + str(XPublicKey_bob))
print("YCoor is: " + str(YPublicKey_bob))

print("Public Key Alice:")
print("XCoor is: " + str(XPublicKey_alice))
print("YCoor is: " + str(YPublicKey_alice))

P = ECadd(PublicKey_bob,PublicKey_alice)
print("P:", P)

k1_bob = 77664663271170673620859955297191590031376319879614890096024130175852238738811 - 1
k2_alice = 89652975980192045565381556847798492396888680198332589948144044069692575244768 - 1

R1 = EccMultiply(GPoint,k1_bob)
R2 = EccMultiply(GPoint,k2_alice)

print("R1: ", R1)
print("R2: ", R2)

R = ECadd(R1,R2)
print("R:", R)

P_bytes = (P[0]).to_bytes(32,'big')
R_bytes = (R[0]).to_bytes(32,'big')

hasher=hashlib.sha256()
hasher.update(P_bytes + R_bytes + msg)
h = hasher.digest()
H = int.from_bytes(h,'big')
print("H:", H)

s1 = (k1_bob + (H * privKey_bob)) % N
s2 = (k2_alice + (H * privKey_alice)) % N

print("s1: ", s1)
print("s2: ", s2)

s = (s1 + s2) % N

v1 = EccMultiply(GPoint,s)

inter = EccMultiply(P,H)

v2 = ECadd(R, inter)

print("v1:", v1)
print("v2:", v2)

if (v1==v2):
  print ("Verified!")
