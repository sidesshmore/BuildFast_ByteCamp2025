
import { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { supabase, CampaignMilestone, Campaign, NGO } from "@/lib/supabase";
import { useQuery } from "@tanstack/react-query";
import { Skeleton } from "@/components/ui/skeleton";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { useToast } from "@/hooks/use-toast";

const Funds = () => {
  const { toast } = useToast();
  const [ngo, setNgo] = useState<NGO | null>(null);

  useEffect(() => {
    const storedNgo = localStorage.getItem('ngo');
    if (storedNgo) {
      setNgo(JSON.parse(storedNgo));
    }
  }, []);

  // Fetch verified milestones
  const { data: verifiedMilestones, isLoading: milestonesLoading, error: milestonesError } = useQuery({
    queryKey: ['verifiedMilestones', ngo?.id],
    enabled: !!ngo?.id,
    queryFn: async () => {
      // Fetch campaigns for this NGO first
      const { data: campaigns, error: campaignsError } = await supabase
        .from('campaigns')
        .select('id')
        .eq('ngo_id', ngo?.id);

      if (campaignsError) {
        throw new Error(campaignsError.message);
      }

      if (!campaigns || campaigns.length === 0) {
        return [];
      }

      const campaignIds = campaigns.map(c => c.id);

      // Fetch verified milestones for these campaigns
      const { data: milestones, error: milestonesError } = await supabase
        .from('campaign_milestones')
        .select('*, campaigns(campaign_name)')
        .in('campaign_id', campaignIds)
        .eq('is_verified', true);

      if (milestonesError) {
        throw new Error(milestonesError.message);
      }

      return milestones || [];
    },
    onError: (error) => {
      console.error("Error fetching milestones:", error);
      toast({
        title: "Error",
        description: "Failed to load disbursed funds data",
        variant: "destructive"
      });
    }
  });

  // Calculate total disbursed amount
  const totalDisbursedAmount = verifiedMilestones?.reduce((total, milestone) => {
    return total + (milestone.funding_required || 0);
  }, 0) || 0;

  if (milestonesError) {
    return (
      <Card className="mb-6">
        <CardHeader>
          <CardTitle className="text-red-500">Error Loading Funds Data</CardTitle>
        </CardHeader>
        <CardContent>
          <p>There was an error loading the disbursed funds data. Please try again later.</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <>
      <Card className="mb-6">
        <CardHeader>
          <CardTitle>Disbursed Funds</CardTitle>
        </CardHeader>
        <CardContent>
          {milestonesLoading ? (
            <div className="space-y-4">
              <Skeleton className="h-12 w-full" />
              <Skeleton className="h-20 w-full" />
            </div>
          ) : (
            <div className="space-y-6">
              <div className="bg-gradient-to-r from-purple-100 to-indigo-100 p-6 rounded-lg shadow-sm">
                <h3 className="text-lg text-gray-700 mb-2">Total Disbursed Amount</h3>
                <p className="text-3xl font-bold text-indigo-700">₹{totalDisbursedAmount.toLocaleString()}</p>
              </div>
              
              {verifiedMilestones && verifiedMilestones.length > 0 ? (
                <>
                  <h3 className="text-lg font-medium mt-6">Verified Milestones</h3>
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Campaign</TableHead>
                        <TableHead>Milestone</TableHead>
                        <TableHead>Target Date</TableHead>
                        <TableHead className="text-right">Amount (₹)</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {verifiedMilestones.map((milestone) => (
                        <TableRow key={milestone.id}>
                          <TableCell className="font-medium">{(milestone.campaigns as any)?.campaign_name || 'Unknown Campaign'}</TableCell>
                          <TableCell>{milestone.milestone_name}</TableCell>
                          <TableCell>{new Date(milestone.target_date).toLocaleDateString()}</TableCell>
                          <TableCell className="text-right">{milestone.funding_required?.toLocaleString() || '0'}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </>
              ) : (
                <div className="text-center py-6 text-gray-500">
                  <p>No verified milestones found. Verified milestones with funding requirements will appear here.</p>
                </div>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </>
  );
};

export default Funds;
