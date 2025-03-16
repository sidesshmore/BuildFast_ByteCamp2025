
import { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
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
import { toast } from "@/hooks/use-toast";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Calendar, ImageIcon, FileText } from "lucide-react";

const campaignSchema = z.object({
  campaign_name: z.string().min(3, { message: "Campaign name must be at least 3 characters" }),
  campaign_description: z.string().min(10, { message: "Description must be at least 10 characters" }),
  image_url: z.string().url({ message: "Please enter a valid URL" }).nullable().optional(),
  funds_required: z.coerce.number().positive({ message: "Funds required must be a positive number" }),
  campign_proposal: z.string().url({ message: "Please enter a valid URL" }).nullable().optional(),
  valid_until: z.string().nullable().optional(),
});

type CampaignFormValues = z.infer<typeof campaignSchema>;

const CampaignForm = () => {
  const [loading, setLoading] = useState(false);
  const [campaignData, setCampaignData] = useState<Campaign | null>(null);
  
  const navigate = useNavigate();
  const { id } = useParams();
  const isEditing = !!id;
  
  const form = useForm<CampaignFormValues>({
    resolver: zodResolver(campaignSchema),
    defaultValues: {
      campaign_name: "",
      campaign_description: "",
      image_url: "",
      funds_required: 0,
      campign_proposal: "",
      valid_until: "",
    },
  });
  
  useEffect(() => {
    const fetchCampaign = async () => {
      if (!isEditing) return;
      
      try {
        const { data, error } = await supabase
          .from('campaigns')
          .select('*')
          .eq('id', id)
          .single();
          
        if (error) {
          throw error;
        }
        
        if (data) {
          setCampaignData(data as Campaign);
          form.reset({
            campaign_name: data.campaign_name,
            campaign_description: data.campaign_description,
            image_url: data.image_url || "",
            funds_required: data.funds_required,
            campign_proposal: data.campign_proposal || "",
            valid_until: data.valid_until ? data.valid_until.substring(0, 10) : "",
          });
        }
      } catch (error) {
        console.error('Error fetching campaign:', error);
        toast({
          title: "Error",
          description: "Failed to fetch campaign details",
          variant: "destructive",
        });
        navigate('/dashboard/campaigns');
      }
    };
    
    fetchCampaign();
  }, [id, isEditing, form, navigate]);
  
  const onSubmit = async (values: CampaignFormValues) => {
    setLoading(true);
    
    try {
      const storedNgo = localStorage.getItem('ngo');
      if (!storedNgo) {
        navigate('/login');
        return;
      }
      
      const ngo = JSON.parse(storedNgo);
      
      if (isEditing) {
        const { error } = await supabase
          .from('campaigns')
          .update({
            campaign_name: values.campaign_name,
            campaign_description: values.campaign_description,
            image_url: values.image_url || null,
            funds_required: values.funds_required,
            campign_proposal: values.campign_proposal || null,
            valid_until: values.valid_until || null,
          })
          .eq('id', id);
          
        if (error) throw error;
        
        toast({
          title: "Success",
          description: "Campaign updated successfully",
        });
      } else {
        const { error } = await supabase
          .from('campaigns')
          .insert({
            campaign_name: values.campaign_name,
            campaign_description: values.campaign_description,
            image_url: values.image_url || null,
            ngo_id: ngo.id,
            funds_required: values.funds_required,
            campign_proposal: values.campign_proposal || null,
            valid_until: values.valid_until || null,
            is_completed: false,
          });
          
        if (error) throw error;
        
        toast({
          title: "Success",
          description: "Campaign created successfully",
        });
      }
      
      navigate('/dashboard/campaigns');
    } catch (error) {
      console.error('Error saving campaign:', error);
      toast({
        title: "Error",
        description: isEditing ? "Failed to update campaign" : "Failed to create campaign",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };
  
  return (
    <div className="max-w-3xl mx-auto">
      <div className="mb-6">
        <Badge variant="secondary" className="mb-2 text-xs font-normal">
          {isEditing ? 'Update Campaign' : 'New Campaign'}
        </Badge>
        <h2 className="text-3xl font-bold">
          {isEditing ? 'Edit Campaign Details' : 'Create a New Campaign'}
        </h2>
        <p className="text-muted-foreground mt-1">
          {isEditing ? 'Update your campaign information below' : 'Fill in the details to create your fundraising campaign'}
        </p>
      </div>
      
      <Card className="border border-border/40 shadow-sm">
        <CardContent className="pt-6">
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
              <FormField
                control={form.control}
                name="campaign_name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Campaign Name</FormLabel>
                    <FormControl>
                      <Input 
                        placeholder="Enter a compelling campaign name" 
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
                name="campaign_description"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Description</FormLabel>
                    <FormControl>
                      <Textarea 
                        placeholder="Describe your campaign's purpose, goals, and impact..." 
                        rows={5}
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
                  name="funds_required"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Funds Required (₹)</FormLabel>
                      <FormControl>
                        <Input 
                          type="number" 
                          min="0" 
                          step="0.01" 
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
                  name="valid_until"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="flex items-center gap-1">
                        <Calendar className="h-4 w-4" /> 
                        Valid Until
                      </FormLabel>
                      <FormControl>
                        <Input 
                          type="date" 
                          {...field} 
                          value={field.value || ""} 
                          className="transition-all focus:ring-2 focus:ring-ring"
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <FormField
                  control={form.control}
                  name="image_url"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="flex items-center gap-1">
                        <ImageIcon className="h-4 w-4" />
                        Campaign Thumbnail URL
                      </FormLabel>
                      <FormControl>
                        <Input 
                          placeholder="Enter image URL" 
                          {...field} 
                          value={field.value || ""}
                          className="transition-all focus:ring-2 focus:ring-ring"
                        />
                      </FormControl>
                      <FormDescription className="text-xs">
                        Enter URL for an engaging image to showcase your campaign
                      </FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                
                <FormField
                  control={form.control}
                  name="campign_proposal"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="flex items-center gap-1">
                        <FileText className="h-4 w-4" />
                        Proposal Document URL
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
                        Enter URL to your detailed campaign proposal document
                      </FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
              
              <div className="flex gap-4 justify-end pt-4">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => navigate('/dashboard/campaigns')}
                  className="border-border/50 hover:bg-secondary/80"
                >
                  Cancel
                </Button>
                <Button 
                  type="submit" 
                  disabled={loading}
                  className="transition-all"
                >
                  {loading ? 'Saving...' : isEditing ? 'Update Campaign' : 'Create Campaign'}
                </Button>
              </div>
            </form>
          </Form>
        </CardContent>
      </Card>
    </div>
  );
};

export default CampaignForm;
