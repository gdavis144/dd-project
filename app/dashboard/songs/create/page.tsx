import Form from '@/app/ui/songs/create-form';
import Breadcrumbs from '@/app/ui/songs/breadcrumbs';
import { fetchAlbumsByUser } from '@/app/lib/data';
 
export default async function Page() { 
  const albums = await fetchAlbumsByUser();
  return (
    <main>
      <Breadcrumbs
        breadcrumbs={[
          { label: 'Songs', href: '/dashboard/songs' },
          {
            label: 'Publish Song',
            href: '/dashboard/songs/create',
            active: true,
          },
        ]}
      />
      <Form />
    </main>
  );
}