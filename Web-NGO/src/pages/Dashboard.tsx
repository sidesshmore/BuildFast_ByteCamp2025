
import { useEffect, useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useNavigate, Outlet } from "react-router-dom";
import { NGO } from "@/lib/supabase";
import { SidebarProvider } from "@/components/ui/sidebar";
import DashboardSidebar from "@/components/DashboardSidebar";

const Dashboard = () => {
  const [ngo, setNgo] = useState<NGO | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    // Check if user is logged in
    const storedNgo = localStorage.getItem('ngo');
    if (!storedNgo) {
      navigate('/login');
      return;
    }
    
    setNgo(JSON.parse(storedNgo));
  }, [navigate]);

  const handleLogout = () => {
    localStorage.removeItem('ngo');
    navigate('/login');
  };

  if (!ngo) return null;

  return (
    <div className="min-h-screen bg-gray-50">
      <SidebarProvider>
        <div className="flex min-h-screen w-full">
          <DashboardSidebar />
          <div className="flex-1 p-4">
            <div className="max-w-4xl mx-auto">
              <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold">NGO Dashboard</h1>
                <Button variant="outline" onClick={handleLogout}>Logout</Button>
              </div>
              
              <Card className="mb-6">
                <CardHeader>
                  <CardTitle>Welcome, {ngo.ngo_name}!</CardTitle>
                  <CardDescription>
                    This is your NGO management dashboard
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <h3 className="font-medium">NGO Details:</h3>
                      <p><span className="font-medium">Administrator:</span> {ngo.administrator_name}</p>
                      <p><span className="font-medium">Email:</span> {ngo.email}</p>
                      <p><span className="font-medium">Phone:</span> {ngo.phone_number || 'N/A'}</p>
                      <p><span className="font-medium">Darpan ID:</span> {ngo.darpan_id}</p>
                      <p><span className="font-medium">Address:</span> {ngo.address}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
              
              <Outlet />
            </div>
          </div>
        </div>
      </SidebarProvider>
    </div>
  );
};

export default Dashboard;
