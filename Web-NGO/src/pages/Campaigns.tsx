
import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useNavigate } from "react-router-dom";
import { Campaign, supabase } from "@/lib/supabase";
import { Edit, Trash, Plus, Calendar, FileText, Loader2 } from "lucide-react";
import { toast } from "@/hooks/use-toast";
import { Badge } from "@/components/ui/badge";

const Campaigns = () => {
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);
  const [loading, setLoading] = useState(true);
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const navigate = useNavigate();
  
  const fetchCampaigns = async () => {
    setLoading(true);
    try {
      const storedNgo = localStorage.getItem('ngo');
      if (!storedNgo) {
        navigate('/login');
        return;
      }
      
      const ngo = JSON.parse(storedNgo);
      
      const { data, error } = await supabase
        .from('campaigns')
        .select('*')
        .eq('ngo_id', ngo.id);
        
      if (error) {
        throw error;
      }
      
      setCampaigns(data || []);
    } catch (error) {
      console.error('Error fetching campaigns:', error);
      toast({
        title: "Error fetching campaigns",
        description: "Please try again later",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };
  
  useEffect(() => {
    fetchCampaigns();
  }, [navigate]);
  
  const handleDelete = async (id: string) => {
    try {
      setDeletingId(id);
      const { error } = await supabase
        .from('campaigns')
        .delete()
        .eq('id', id);
        
      if (error) {
        throw error;
      }
      
      toast({
        title: "Campaign deleted",
        description: "The campaign has been deleted successfully",
      });
      
      // Refresh the campaigns list
      fetchCampaigns();
    } catch (error) {
      console.error('Error deleting campaign:', error);
      toast({
        title: "Error deleting campaign",
        description: "Please try again later",
        variant: "destructive"
      });
    } finally {
      setDeletingId(null);
    }
  };
  
  return (
    <div className="container px-0">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h2 className="text-3xl font-bold">Your Campaigns</h2>
          <p className="text-muted-foreground mt-1">Manage your fundraising campaigns</p>
        </div>
        <Button onClick={() => navigate('/dashboard/campaigns/new')} className="gap-1">
          <Plus className="h-4 w-4" /> New Campaign
        </Button>
      </div>
      
      {loading ? (
        <div className="flex justify-center py-12">
          <div className="flex flex-col items-center gap-2">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
            <p className="text-sm text-muted-foreground">Loading campaigns...</p>
          </div>
        </div>
      ) : campaigns.length === 0 ? (
        <Card className="border border-border/40 shadow-sm">
          <CardContent className="flex flex-col items-center justify-center py-12">
            <div className="rounded-full bg-secondary w-16 h-16 flex items-center justify-center mb-4">
              <Plus className="h-6 w-6 text-secondary-foreground/70" />
            </div>
            <h3 className="text-xl font-medium mb-2">No campaigns yet</h3>
            <p className="text-center text-muted-foreground max-w-md mb-6">
              You haven't created any campaigns yet. Start raising funds for your cause by creating your first campaign.
            </p>
            <Button onClick={() => navigate('/dashboard/campaigns/new')} className="gap-1">
              <Plus className="h-4 w-4" /> Create Your First Campaign
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {campaigns.map((campaign) => (
            <Card key={campaign.id} className="overflow-hidden border border-border/40 shadow-sm transition-all hover:shadow-md">
              <div className="relative">
                {campaign.image_url ? (
                  <div className="h-48 overflow-hidden">
                    <img 
                      src={campaign.image_url} 
                      alt={campaign.campaign_name} 
                      className="w-full h-full object-cover transition-transform hover:scale-105 duration-500"
                    />
                  </div>
                ) : (
                  <div className="h-48 bg-secondary/40 flex items-center justify-center">
                    <p className="text-muted-foreground text-sm">No image available</p>
                  </div>
                )}
                <div className="absolute top-2 right-2">
                  <Badge variant={campaign.is_completed ? "secondary" : "success"} className="text-xs font-normal">
                    {campaign.is_completed ? 'Completed' : 'Ongoing'}
                  </Badge>
                </div>
              </div>
              <CardHeader className="pb-2">
                <CardTitle className="line-clamp-1">{campaign.campaign_name}</CardTitle>
              </CardHeader>
              <CardContent className="pb-2">
                <p className="text-sm text-muted-foreground mb-4 line-clamp-3">
                  {campaign.campaign_description}
                </p>
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between items-center">
                    <span className="font-medium">Funds Required:</span>
                    <span className="font-semibold">₹{campaign.funds_required.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="font-medium">Funds Collected:</span>
                    <span>{(campaign.funds_collected || 0) > 0 ? 
                      `₹${(campaign.funds_collected || 0).toLocaleString()}` : 
                      '₹0'}
                    </span>
                  </div>
                  {campaign.valid_until && (
                    <div className="flex justify-between items-center">
                      <span className="font-medium flex items-center gap-1">
                        <Calendar className="h-3 w-3" /> Valid Until:
                      </span>
                      <span>{new Date(campaign.valid_until).toLocaleDateString()}</span>
                    </div>
                  )}
                  {campaign.campign_proposal && (
                    <div className="flex items-center gap-1 text-primary mt-2">
                      <FileText className="h-3 w-3" />
                      <a href={campaign.campign_proposal} target="_blank" rel="noopener noreferrer" className="text-xs hover:underline">
                        View Proposal
                      </a>
                    </div>
                  )}
                </div>
              </CardContent>
              <CardFooter className="flex justify-end gap-2 pt-2">
                <Button 
                  variant="outline" 
                  size="sm" 
                  onClick={() => navigate(`/dashboard/campaigns/edit/${campaign.id}`)}
                  className="border-border/50 hover:bg-secondary/80"
                >
                  <Edit className="h-3.5 w-3.5 mr-1" /> Edit
                </Button>
                <Button 
                  variant="destructive" 
                  size="sm"
                  onClick={() => handleDelete(campaign.id)}
                  disabled={deletingId === campaign.id}
                >
                  {deletingId === campaign.id ? (
                    <Loader2 className="h-3.5 w-3.5 animate-spin mr-1" />
                  ) : (
                    <Trash className="h-3.5 w-3.5 mr-1" />
                  )}
                  Delete
                </Button>
              </CardFooter>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};

export default Campaigns;
