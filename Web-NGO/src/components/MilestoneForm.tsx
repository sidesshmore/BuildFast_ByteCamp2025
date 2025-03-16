
import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { z } from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Campaign, supabase } from "@/lib/supabase";
import { Button } from "@/components/ui/button";
import { 
  Form, 
  FormControl, 
  FormField, 
  FormItem, 
  FormLabel, 
  FormMessage,
  FormDescription
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from "@/components/ui/select";
import { toast } from "@/hooks/use-toast";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Calendar, FileText, Target } from "lucide-react";

const milestoneSchema = z.object({
  milestone_name: z.string().min(3, { message: "Milestone name must be at least 3 characters" }),
  campaign_id: z.string().uuid({ message: "Please select a campaign" }),
  description: z.string().min(10, { message: "Description must be at least 10 characters" }),
  target_date: z.string().refine(val => !!val, { message: "Please select a target date" }),
  funding_required: z.coerce.number().nonnegative().optional(),
  document_url: z.string().url({ message: "Please enter a valid URL" }).nullable().optional(),
});

type MilestoneFormValues = z.infer<typeof milestoneSchema>;

const MilestoneForm = () => {
  const [loading, setLoading] = useState(false);
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);
  const navigate = useNavigate();
  
  const form = useForm<MilestoneFormValues>({
    resolver: zodResolver(milestoneSchema),
    defaultValues: {
      milestone_name: "",
      campaign_id: "",
      description: "",
      target_date: "",
      funding_required: 0,
      document_url: "",
    },
  });
  
  useEffect(() => {
    const fetchCampaigns = async () => {
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
          .eq('ngo_id', ngo.id)
          .order('campaign_name', { ascending: true });
          
        if (error) {
          throw error;
        }
        
        setCampaigns(data || []);
        
        if (data && data.length === 0) {
          toast({
            title: "No campaigns found",
            description: "Please create a campaign first before adding milestones",
          });
          navigate('/dashboard/campaigns/new');
        }
      } catch (error) {
        console.error('Error fetching campaigns:', error);
        toast({
          title: "Error",
          description: "Failed to fetch campaigns",
          variant: "destructive",
        });
      }
    };
    
    fetchCampaigns();
  }, [navigate]);
  
  const onSubmit = async (values: MilestoneFormValues) => {
    setLoading(true);
    
    try {
      const { error } = await supabase
        .from('campaign_milestones')
        .insert({
          milestone_name: values.milestone_name,
          campaign_id: values.campaign_id,
          description: values.description,
          target_date: values.target_date,
          funding_required: values.funding_required || 0,
          document_url: values.document_url || null,
        });
        
      if (error) throw error;
      
      toast({
        title: "Success",
        description: "Milestone added successfully",
      });
      
      navigate('/dashboard/milestones');
    } catch (error) {
      console.error('Error saving milestone:', error);
      toast({
        title: "Error",
        description: "Failed to add milestone",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };
  
  return (
    <div className="max-w-2xl mx-auto">
      <div className="mb-6">
        <h2 className="text-3xl font-bold">Add New Milestone</h2>
        <p className="text-muted-foreground mt-1">Track progress by adding key milestones to your campaign</p>
      </div>
      
      <Card className="border border-border/40 shadow-sm">
        <CardHeader className="pb-2">
          <CardTitle className="text-xl">Milestone Details</CardTitle>
          <CardDescription>Fill in the information to add a new milestone to your campaign</CardDescription>
        </CardHeader>
        
        <CardContent>
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
              <FormField
                control={form.control}
                name="campaign_id"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Campaign</FormLabel>
                    <Select 
                      onValueChange={field.onChange} 
                      defaultValue={field.value}
                    >
                      <FormControl>
                        <SelectTrigger className="transition-all focus:ring-2 focus:ring-ring">
                          <SelectValue placeholder="Select a campaign" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {campaigns.map((campaign) => (
                          <SelectItem key={campaign.id} value={campaign.id}>
                            {campaign.campaign_name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />
              
              <FormField
                control={form.control}
                name="milestone_name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Milestone Name</FormLabel>
                    <FormControl>
                      <Input 
                        placeholder="Enter milestone name" 
                        {...field} 
                        className="transition-all focus:ring-2 focus:ring-ring"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              
              <FormField
                control={form.control}
                name="description"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Description</FormLabel>
                    <FormControl>
                      <Textarea 
                        placeholder="Describe this milestone and its importance" 
                        rows={4}
                        {...field} 
                        className="resize-none transition-all focus:ring-2 focus:ring-ring"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <FormField
                  control={form.control}
                  name="target_date"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="flex items-center gap-1">
                        <Calendar className="h-4 w-4" />
                        Target Date
                      </FormLabel>
                      <FormControl>
                        <Input 
                          type="date" 
                          {...field} 
                          className="transition-all focus:ring-2 focus:ring-ring"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                
                <FormField
                  control={form.control}
                  name="funding_required"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="flex items-center gap-1">
                        <Target className="h-4 w-4" />
                        Funding Required (₹)
                      </FormLabel>
                      <FormControl>
                        <Input 
                          type="number" 
                          min="0" 
                          step="0.01" 
                          placeholder="0.00"
                          {...field} 
                          className="transition-all focus:ring-2 focus:ring-ring"
                        />
                      </FormControl>
                      <FormDescription className="text-xs">
                        Optional: Amount needed for this milestone
                      </FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
              
              <FormField
                control={form.control}
                name="document_url"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="flex items-center gap-1">
                      <FileText className="h-4 w-4" />
                      Supporting Document URL
                    </FormLabel>
                    <FormControl>
                      <Input 
                        placeholder="Enter document URL" 
                        {...field} 
                        value={field.value || ""}
                        className="transition-all focus:ring-2 focus:ring-ring"
                      />
                    </FormControl>
                    <FormDescription className="text-xs">
                      URL to a document with additional details or evidence
                    </FormDescription>
                    <FormMessage />
                  </FormItem>
                )}
              />
              
              <div className="flex gap-4 justify-end pt-4">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => navigate('/dashboard/milestones')}
                  className="border-border/50 hover:bg-secondary/80"
                >
                  Cancel
                </Button>
                <Button 
                  type="submit" 
                  disabled={loading}
                  className="transition-all"
                >
                  {loading ? 'Adding...' : 'Add Milestone'}
                </Button>
              </div>
            </form>
          </Form>
        </CardContent>
      </Card>
    </div>
  );
};

export default MilestoneForm;
