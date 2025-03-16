
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useNavigate, useLocation } from "react-router-dom";
import {
  Sidebar,
  SidebarContent,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuItem,
  SidebarMenuButton,
} from "@/components/ui/sidebar";
import { Flag, Milestone, Wallet } from "lucide-react";

const DashboardSidebar = () => {
  const navigate = useNavigate();
  const location = useLocation();
  
  // Determine which tab is active based on the current path
  const getActiveTab = () => {
    if (location.pathname.includes("/milestones")) {
      return "milestones";
    } else if (location.pathname.includes("/funds")) {
      return "funds";
    } else {
      return "campaigns";
    }
  };

  const activeTab = getActiveTab();

  const handleTabChange = (value: string) => {
    if (value === "campaigns") {
      navigate("/dashboard/campaigns");
    } else if (value === "milestones") {
      navigate("/dashboard/milestones");
    } else if (value === "funds") {
      navigate("/dashboard/funds");
    }
  };

  return (
    <Sidebar>
      <SidebarHeader>
        <Tabs
          defaultValue={activeTab}
          onValueChange={handleTabChange}
          className="w-full"
        >
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="campaigns">Campaigns</TabsTrigger>
            <TabsTrigger value="milestones">Milestones</TabsTrigger>
            <TabsTrigger value="funds">Funds</TabsTrigger>
          </TabsList>
        </Tabs>
      </SidebarHeader>
      <SidebarContent>
        <SidebarMenu>
          {activeTab === "campaigns" && (
            <SidebarMenuItem>
              <SidebarMenuButton onClick={() => navigate("/dashboard/campaigns/new")}>
                <Flag />
                <span>Create New Campaign</span>
              </SidebarMenuButton>
            </SidebarMenuItem>
          )}
          {activeTab === "milestones" && (
            <SidebarMenuItem>
              <SidebarMenuButton onClick={() => navigate("/dashboard/milestones/new")}>
                <Milestone />
                <span>Add New Milestone</span>
              </SidebarMenuButton>
            </SidebarMenuItem>
          )}
          {activeTab === "funds" && (
            <SidebarMenuItem>
              <SidebarMenuButton onClick={() => navigate("/dashboard/funds")}>
                <Wallet />
                <span>View Disbursed Funds</span>
              </SidebarMenuButton>
            </SidebarMenuItem>
          )}
        </SidebarMenu>
      </SidebarContent>
    </Sidebar>
  );
};

export default DashboardSidebar;
