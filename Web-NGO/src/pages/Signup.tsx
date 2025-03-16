
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { useToast } from "@/hooks/use-toast";
import { supabase } from "@/lib/supabase";
import { Link, useNavigate } from "react-router-dom";

const Signup = () => {
  const [ngoName, setNgoName] = useState("");
  const [address, setAddress] = useState("");
  const [administratorName, setAdministratorName] = useState("");
  const [email, setEmail] = useState("");
  const [phoneNumber, setPhoneNumber] = useState("");
  const [darpanId, setDarpanId] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  
  const { toast } = useToast();
  const navigate = useNavigate();

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      // Check if email already exists
      const { data: existingEmail } = await supabase
        .from('ngo_details')
        .select('email')
        .eq('email', email)
        .single();

      if (existingEmail) {
        throw new Error("Email already in use");
      }

      // Check if Darpan ID already exists
      const { data: existingDarpanId } = await supabase
        .from('ngo_details')
        .select('darpan_id')
        .eq('darpan_id', darpanId)
        .single();

      if (existingDarpanId) {
        throw new Error("Darpan ID already registered");
      }

      // Create new NGO record
      const { data: newNgo, error } = await supabase
        .from('ngo_details')
        .insert([
          {
            ngo_name: ngoName,
            address,
            administrator_name: administratorName,
            email,
            phone_number: phoneNumber,
            darpan_id: darpanId,
            password
          }
        ])
        .select()
        .single();

      if (error) throw error;

      toast({
        title: "Registration Successful",
        description: "Your NGO has been registered successfully!",
      });

      // Store NGO data in localStorage
      localStorage.setItem('ngo', JSON.stringify(newNgo));
      
      navigate("/dashboard");
    } catch (error: any) {
      toast({
        title: "Registration Failed",
        description: error.message || "Please check your details and try again.",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4 py-8">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1">
          <CardTitle className="text-2xl font-bold text-center">NGO Registration</CardTitle>
          <CardDescription className="text-center">
            Create an account for your organization
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSignup} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="ngo-name">NGO Name</Label>
              <Input
                id="ngo-name"
                value={ngoName}
                onChange={(e) => setNgoName(e.target.value)}
                required
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="address">Address</Label>
              <Input
                id="address"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
                required
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="administrator-name">Administrator Name</Label>
              <Input
                id="administrator-name"
                value={administratorName}
                onChange={(e) => setAdministratorName(e.target.value)}
                required
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="phone-number">Phone Number</Label>
              <Input
                id="phone-number"
                value={phoneNumber}
                onChange={(e) => setPhoneNumber(e.target.value)}
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="darpan-id">Darpan ID</Label>
              <Input
                id="darpan-id"
                value={darpanId}
                onChange={(e) => setDarpanId(e.target.value)}
                required
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            
            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? "Creating Account..." : "Sign Up"}
            </Button>
          </form>
        </CardContent>
        <CardFooter className="flex justify-center">
          <p className="text-sm text-gray-600">
            Already have an account?{" "}
            <Link to="/login" className="font-medium text-blue-600 hover:underline">
              Log in
            </Link>
          </p>
        </CardFooter>
      </Card>
    </div>
  );
};

export default Signup;
