
import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { useNavigate } from "react-router-dom";
import { Campaign, Milestone, supabase } from "@/lib/supabase";
import { toast } from "@/hooks/use-toast";
import { Badge } from "@/components/ui/badge";
import { Check, Clock, Plus, Calendar, Target, FileText, Loader2 } from "lucide-react";

const Milestones = () => {
  const [milestones, setMilestones] = useState<Milestone[]>([]);
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  
  const fetchData = async () => {
    setLoading(true);
    try {
      const storedNgo = localStorage.getItem('ngo');
      if (!storedNgo) {
        navigate('/login');
        return;
      }
      
      const ngo = JSON.parse(storedNgo);
      
      // Fetch campaigns
      const { data: campaignsData, error: campaignsError } = await supabase
        .from('campaigns')
        .select('*')
        .eq('ngo_id', ngo.id);
        
      if (campaignsError) {
        throw campaignsError;
      }
      
      setCampaigns(campaignsData || []);
      
      if (campaignsData && campaignsData.length > 0) {
        // Fetch milestones for these campaigns
        const campaignIds = campaignsData.map(campaign => campaign.id);
        
        const { data: milestonesData, error: milestonesError } = await supabase
          .from('campaign_milestones')
          .select('*')
          .in('campaign_id', campaignIds)
          .order('target_date', { ascending: true });
          
        if (milestonesError) {
          throw milestonesError;
        }
        
        setMilestones(milestonesData || []);
      }
    } catch (error) {
      console.error('Error fetching data:', error);
      toast({
        title: "Error fetching data",
        description: "Please try again later",
        variant: "destructive"
      });
    } finally {
      setLoading(false);
    }
  };
  
  useEffect(() => {
    fetchData();
  }, [navigate]);
  
  const getCampaignName = (campaignId: string) => {
    const campaign = campaigns.find(c => c.id === campaignId);
    return campaign ? campaign.campaign_name : 'Unknown Campaign';
  };
  
  return (
    <div className="container px-0">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h2 className="text-3xl font-bold">Campaign Milestones</h2>
          <p className="text-muted-foreground mt-1">Track progress with key milestones</p>
        </div>
        <Button onClick={() => navigate('/dashboard/milestones/new')} className="gap-1">
          <Plus className="h-4 w-4" /> Add Milestone
        </Button>
      </div>
      
      {loading ? (
        <div className="flex justify-center py-12">
          <div className="flex flex-col items-center gap-2">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
            <p className="text-sm text-muted-foreground">Loading milestones...</p>
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
              You need to create a campaign first before adding milestones.
            </p>
            <Button onClick={() => navigate('/dashboard/campaigns/new')} className="gap-1">
              <Plus className="h-4 w-4" /> Create Your First Campaign
            </Button>
          </CardContent>
        </Card>
      ) : milestones.length === 0 ? (
        <Card className="border border-border/40 shadow-sm">
          <CardContent className="flex flex-col items-center justify-center py-12">
            <div className="rounded-full bg-secondary w-16 h-16 flex items-center justify-center mb-4">
              <Target className="h-6 w-6 text-secondary-foreground/70" />
            </div>
            <h3 className="text-xl font-medium mb-2">No milestones yet</h3>
            <p className="text-center text-muted-foreground max-w-md mb-6">
              Add milestones to track progress towards your campaign goals.
            </p>
            <Button onClick={() => navigate('/dashboard/milestones/new')} className="gap-1">
              <Plus className="h-4 w-4" /> Add Your First Milestone
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-6">
          {milestones.map((milestone) => (
            <Card key={milestone.id} className="border border-border/40 shadow-sm overflow-hidden transition-all hover:shadow-md">
              <CardHeader className="pb-2">
                <div className="flex justify-between items-start">
                  <div>
                    <CardTitle>{milestone.milestone_name}</CardTitle>
                    <CardDescription>
                      Campaign: {getCampaignName(milestone.campaign_id)}
                    </CardDescription>
                  </div>
                  <Badge variant={milestone.is_verified ? "success" : "warning"}>
                    {milestone.is_verified ? (
                      <><Check className="h-3 w-3 mr-1" /> Verified</>
                    ) : (
                      <><Clock className="h-3 w-3 mr-1" /> Pending Verification</>
                    )}
                  </Badge>
                </div>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <p className="text-sm text-muted-foreground">{milestone.description}</p>
                  
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4 bg-secondary/20 p-3 rounded-md">
                    <div className="flex items-center gap-2">
                      <Calendar className="h-4 w-4 text-primary" />
                      <div>
                        <p className="text-xs text-muted-foreground">Target Date</p>
                        <p className="font-medium">{new Date(milestone.target_date).toLocaleDateString()}</p>
                      </div>
                    </div>
                    
                    {milestone.funding_required && milestone.funding_required > 0 && (
                      <div className="flex items-center gap-2">
                        <Target className="h-4 w-4 text-primary" />
                        <div>
                          <p className="text-xs text-muted-foreground">Funding Required</p>
                          <p className="font-medium">₹{milestone.funding_required.toLocaleString()}</p>
                        </div>
                      </div>
                    )}
                    
                    {milestone.created_at && (
                      <div className="flex items-center gap-2">
                        <Clock className="h-4 w-4 text-primary" />
                        <div>
                          <p className="text-xs text-muted-foreground">Added On</p>
                          <p className="font-medium">{new Date(milestone.created_at).toLocaleDateString()}</p>
                        </div>
                      </div>
                    )}
                  </div>
                  
                  {milestone.document_url && (
                    <CardFooter className="px-0 pt-2 pb-0 flex">
                      <a 
                        href={milestone.document_url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-1 text-primary hover:underline hover:text-primary/80 transition-colors"
                      >
                        <FileText className="h-4 w-4" />
                        <span>View Supporting Document</span>
                      </a>
                    </CardFooter>
                  )}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};

export default Milestones;
